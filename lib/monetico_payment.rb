require 'openssl'
require 'base64'

#
# Please take note of these important license terms, copied from "MIT-LICENSE.txt"
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# In particular, this software may not be compliant with any version of monetico,
# it may not work, it may send money in the wrong direction, it may siphon cash away
# to untraceable offshore accounts, it may cause you to get fired, sued, bankrupt and/or
# divorced, and also lose your hair and/or custody of your children. By using this software you
# indemnify, defend, and hold harmless the authors, copyright holders, and relevant
# financial institutions from liability and damages of any kind arising directly or indirectly
# from the use of this software.
#
# By using this software you agree that you are using the software entirely at your own risk
# and peril, and that you have inspected the source code of the software and that you have
# satisfied yourself that the software does exactly what you expect it to do.
#
# The author is not in any way connected to or affiliated with Monetico, Crédit Mutuel, CIC, or
# Euro-Information. No banking or financial institution has authorised, financed,
# approved, verified or condoned this software. All trademarks are registered trademarks
# of their respective owners.
#
# ================
#
# You may prefer to use the development kit downloadable here:
# https://www.monetico-paiement.fr/fr/installer/telechargements.html
#
# usage :
#
# message validation
#
# params = request.request_parameters  # or whatever you use to get POST params
# mp = MoneticoPayment.new(secret_key)
# valid = mp.validate                  # true if MAC matches ; false otherwise
#
#
# message creation
#
# billing_info = { # make sure you have at least these keys, see docs for others
#   civility: "",
#   firstName: "",
#   lastName: "",
#   addressLine1: "",
#   city: "",
#   postalCode: "",
#   country: "",
#   email: "",
#   mobilePhone: ""
# }
#
# mp = MoneticoPayment.new(key: secret_key,
#                          tpe: "1234567",
#                          date: Time.now,
#                          montant: "12.34",
#                          currency: "EUR",
#                          reference: "F-19/3475"       # invoice number or whatever
#                          url_retour_ok: "https://dom.example.com/pay/success",
#                          url_retour_err: "https://dom.example.com/pay/failure",
#                          lgue: "FR",
#                          societe: "Ma Societe",
#                          contexte_commande: { billing: billing_info },
#                          texte_libre: "Ton argent est notre priorite",
#                          mail: "client-name@son-domain.example.com" ) # mail: optional
#
class MoneticoPayment < Aduki::Initializable
  ATTRS = { "version"           => { value: ->(mp) { mp.version || "3.0" } },
            "tpe"               => { name: "TPE" },
            "date"              => { value: ->(mp) { mp.date.strftime("%d/%m/%Y_a_%H:%M:%S") } },
            "montant"           => { value: ->(mp) { ("%.2f" % mp.montant) + (mp.currency || "EUR") } },
            "reference"         => { },
            "url_retour_ok"     => { },
            "url_retour_err"    => { },
            "lgue"              => { },
            "societe"           => { },
            "contexte_commande" => { value: ->(mp) { Base64.strict_encode64(mp.contexte_commande.to_json).strip } },
            "texte_libre"       => { name: "texte-libre" },
            "mail"              => { }
          }
  attr_accessor :key, :currency, *(ATTRS.keys)

  # POST params only, ignore query params and other params ; in rails use req.request_parameters
  # assumes params keys are symbols
  def validate params
    given_mac = params.delete :MAC
    message   = params.keys.map(&:to_s).sort.map { |f| "#{f}=#{params[f.to_sym]}" }.join('*')
    calc_mac  = hmac_sha1(hmac_key, message)
    given_mac == calc_mac
  end

  def hash_data_item attr, cfg, name=cfg[:name], val=cfg[:value]
    [(name ? name : attr), (val ? val.call(self) : send(attr))]
  end

  def map_attrs         ; ATTRS.keys.sort.map { |a| yield a }                               ; end
  def hash_data         ; map_attrs { |a| hash_data_item(a, ATTRS[a]).join("=") }.join('*') ; end
  def hidden_input n, v ; "<input type='hidden' name='#{n}' value='#{v}'/>"                 ; end
  def hidden_inputs     ; map_attrs { |a| hidden_input *hash_data_item(a, ATTRS[a]) }.join  ; end
  def mac               ; hmac_sha1(hmac_key, hash_data)                                    ; end
  def hmac_sha1 k, data ; OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), k, data)     ; end

  def hmac_key
    k0   = key[0..37]
    k1   = key[38..40] + "00"
    cca0 = k1.ord

    k0 += if cca0>70 and cca0<97
            (cca0-23).chr + k1[1..2]
          elsif k1[1..2] == "M"
            k1[0..1] + "0"
          else
            k1[0..2]
          end

    [k0].pack("H*")
  end
end
