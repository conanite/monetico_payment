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

    expect(mp.mac).to eq "bc7569e8ea32ef97965c15d20e7851a1d7609fb2"
    expect(mp.hidden_inputs.gsub(/></, ">\n<")).to eq "
<input type='hidden' name='contexte_commande' value='eyJiaWxsaW5nIjp7ImFkZHJlc3NMaW5lMSI6IjIgVmlsbGEgZGUgbCdIZXJtaXQiLCJjaXR5IjoiUGFyaXMiLCJwb3N0YWxDb2RlIjoiNzUwOTkiLCJjb3VudHJ5IjoiRlIiLCJjaXZpbGl0eSI6Ik0iLCJmaXJzdE5hbWUiOiJDbGludCIsImxhc3ROYW1lIjoiRWFzdHdvb2QifX0='/>
<input type='hidden' name='date' value='01/01/2020_a_12:34:56'/>
<input type='hidden' name='lgue' value='FR'/>
<input type='hidden' name='mail' value='client-name@son-domain.example.com'/>
<input type='hidden' name='montant' value='123.45EUR'/>
<input type='hidden' name='reference' value='F-20/30405'/>
<input type='hidden' name='societe' value='Ma Societe'/>
<input type='hidden' name='texte-libre' value='Ton argent est notre priorite'/>
<input type='hidden' name='TPE' value='1234567'/>
<input type='hidden' name='url_retour_err' value='https://dom.example.com/pay/failure'/>
<input type='hidden' name='url_retour_ok' value='https://dom.example.com/pay/success'/>
<input type='hidden' name='version' value='3.0'/>
".strip
  end

end
