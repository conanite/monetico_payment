require 'json'

RSpec.describe MoneticoPayment do
  let(:now) { Time.new(2020, 1, 1, 12, 34, 56) }
  let(:key) { "STRINGWITHTOPSECRETBYTESFORKEY01234567890123456789" }
  let(:contexte_commande) { {"billing":{"addressLine1":"2 Villa de l'Hermit","city":"Paris","postalCode":"75099","country":"FR","civility":"M","firstName":"Clint","lastName":"Eastwood"}} }

  it "validates a MAC" do
    params = {
      MAC: "f91ad16668973906e40e8fbe734bf9d194913be4",
      TPE: "1234567",
      date: now,
      montant: 123.45,
      currency: "EUR",
      reference: "F-20/30405",
      url_retour_ok: "https://dom.example.com/pay/success",
      url_retour_err: "https://dom.example.com/pay/failure",
      lgue: "FR",
      societe: "Ma Societe",
      contexte_commande: contexte_commande,
      texte_libre: "Ton argent est notre priorite",
      mail: "client-name@son-domaine.example.com"
    }

    mp = MoneticoPayment.new(key: key)

    expect(mp.validate(params)).to eq true
  end

  it "does not validate the wrong MAC" do
    params = {
      MAC: "WRONG MAC !! f91ad16668973906e40e8fbe734bf9d194913be4", # changed
      TPE: "1234567",
      date: now,
      montant: 123.45,
      currency: "EUR",
      reference: "F-20/30405",
      url_retour_ok: "https://dom.example.com/pay/success",
      url_retour_err: "https://dom.example.com/pay/failure",
      lgue: "FR",
      societe: "Ma Societe",
      contexte_commande: contexte_commande,
      texte_libre: "Ton argent est notre priorite",
      mail: "client-name@son-domaine.example.com"
    }

    mp = MoneticoPayment.new(key: key)

    expect(mp.validate(params)).to eq false
  end

  it "does not validate the MAC for the wrong content" do
    params = {
      MAC: "f91ad16668973906e40e8fbe734bf9d194913be4",
      TPE: "1234567",
      date: now,
      montant: 12345.67,                     # changed amount
      currency: "EUR",
      reference: "F-20/30405",
      url_retour_ok: "https://dom.example.com/pay/success",
      url_retour_err: "https://dom.example.com/pay/failure",
      lgue: "FR",
      societe: "Ma Societe",
      contexte_commande: contexte_commande,
      texte_libre: "Ton argent est notre priorite",
      mail: "client-name@son-domaine.example.com"
    }

    mp = MoneticoPayment.new(key: key)

    expect(mp.validate(params)).to eq false
  end

  it "generates inputs, including MAC" do
    mp = MoneticoPayment.new(key: key,
                             tpe: "1234567",
                             date: now,
                             montant: 123.45,
                             currency: "EUR",
                             reference: "F-20/30405",
                             url_retour_ok: "https://dom.example.com/pay/success",
                             url_retour_err: "https://dom.example.com/pay/failure",
                             lgue: "FR",
                             societe: "Ma Societe",
                             contexte_commande: contexte_commande,
                             texte_libre: "Ton argent est notre priorite",
                             mail: "client-name@son-domain.example.com")


    expect(mp.mac).to eq "67a0d2428715fc6a7c0afb70fce439831cd0b9af"
    expect(mp.hidden_inputs.gsub(/></, ">\n<")).to eq "
<input type='hidden' name='MAC' value='67a0d2428715fc6a7c0afb70fce439831cd0b9af'/>
<input type='hidden' name='TPE' value='1234567'/>
<input type='hidden' name='contexte_commande' value='eyJiaWxsaW5nIjp7ImFkZHJlc3NMaW5lMSI6IjIgVmlsbGEgZGUgbCdIZXJtaXQiLCJjaXR5IjoiUGFyaXMiLCJwb3N0YWxDb2RlIjoiNzUwOTkiLCJjb3VudHJ5IjoiRlIiLCJjaXZpbGl0eSI6Ik0iLCJmaXJzdE5hbWUiOiJDbGludCIsImxhc3ROYW1lIjoiRWFzdHdvb2QifX0='/>
<input type='hidden' name='date' value='01/01/2020:12:34:56'/>
<input type='hidden' name='lgue' value='FR'/>
<input type='hidden' name='mail' value='client-name@son-domain.example.com'/>
<input type='hidden' name='montant' value='123.45EUR'/>
<input type='hidden' name='reference' value='F-20/30405'/>
<input type='hidden' name='societe' value='Ma Societe'/>
<input type='hidden' name='texte-libre' value='Ton argent est notre priorite'/>
<input type='hidden' name='url_retour_err' value='https://dom.example.com/pay/failure'/>
<input type='hidden' name='url_retour_ok' value='https://dom.example.com/pay/success'/>
<input type='hidden' name='version' value='3.0'/>
".strip
  end

  it "generates a query string to append to an IFRAME src url" do
    mp = MoneticoPayment.new(key: key,
                             tpe: "1234567",
                             date: now,
                             montant: 123.45,
                             currency: "EUR",
                             reference: "F-20/30405",
                             url_retour_ok: "https://dom.example.com/pay?success=success",
                             url_retour_err: "https://dom.example.com/pay?success=failure",
                             lgue: "FR",
                             societe: "Ma Societe",
                             contexte_commande: contexte_commande,
                             texte_libre: "Ton argent est notre priorite",
                             mail: "client-name@son-domain.example.com")

    expect(mp.mac).to eq "3c27ea94d9ae35b38ebc3184918fea37e52765b5"

    expected = [
      "MAC=e49ccdcada725802b3e00dec0488b83997489940",
      "TPE=1234567",
      "contexte_commande=eyJiaWxsaW5nIjp7ImFkZHJlc3NMaW5lMSI6IjIgVmlsbGEgZGUgbCdIZXJtaXQiLCJjaXR5IjoiUGFyaXMiLCJwb3N0YWxDb2RlIjoiNzUwOTkiLCJjb3VudHJ5IjoiRlIiLCJjaXZpbGl0eSI6Ik0iLCJmaXJzdE5hbWUiOiJDbGludCIsImxhc3ROYW1lIjoiRWFzdHdvb2QifX0%3D",
      "date=01%2F01%2F2020%3A12%3A34%3A56",
      "lgue=FR",
      "mail=client-name%40son-domain%2Eexample%2Ecom",
      "mode_affichage=iframe",
      "montant=123%2E45EUR",
      "reference=F-20%2F30405",
      "societe=Ma%20Societe",
      "texte-libre=Ton%20argent%20est%20notre%20priorite",
      "url_retour_err=https%3A%2F%2Fdom%2Eexample%2Ecom%2Fpay%3Fsuccess%3Dfailure",
      "url_retour_ok=https%3A%2F%2Fdom%2Eexample%2Ecom%2Fpay%3Fsuccess%3Dsuccess",
      "version=3%2E0"
    ].join("&")

    expect(mp.iframe_params).to eq expected
  end

end
