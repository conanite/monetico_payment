# MoneticoPayment

Please take note of these important license terms, copied from "MIT-LICENSE.txt"

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

In particular, this software is not suitable for production use, may not be compliant
with any version of monetico, it may not work, it may send money in the wrong direction or
to the wrong place, in particular to untraceable offshore accounts, it may cause you to get
fired, sued, bankrupt and/or divorced, and also lose your hair and/or custody of your children.
By using this software you indemnify, defend, and hold harmless the authors, copyright
holders, and financial institutions from liability and damages of any kind arising
directly or indirectly from the use of this software.

By using this software you agree that you are using the software entirely at your own risk
and peril, and that you have inspected the source code of the software and that you have
satisfied yourself that the software does exactly what you expect it to do.

The author is not in any way connected to or affiliated with Monetico, Crédit Mutuel, CIC, or
Euro-Information. No banking or financial institution has authorised, financed,
approved, verified or condoned this software. All trademarks are registered trademarks
of their respective owners.

================

You may prefer to use the development kit downloadable here:
https://www.monetico-paiement.fr/fr/installer/telechargements.html


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'monetico_payment'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install monetico_payment

## Usage

### message validation

```ruby
params = request.request_parameters  # or whatever you use to get POST params
mp = MoneticoPayment.new(secret_key)
valid = mp.validate                  # true if MAC matches ; false otherwise
```


### message creation

```ruby
billing_info = { # make sure you have at least these keys, see docs for others
  civility: "",
  firstName: "",
  lastName: "",
  addressLine1: "",
  city: "",
  postalCode: "",
  country: "",
  email: "",
  mobilePhone: ""
}

mp = MoneticoPayment.new(key:               secret_key,
                         tpe:               "1234567",
                         date:               Time.now,
                         montant:           "12.34",
                         currency:          "EUR",
                         reference:         "F-19/3475"       # invoice number or whatever
                         url_retour_ok:     "https://dom.example.com/pay/success",
                         url_retour_err:    "https://dom.example.com/pay/failure",
                         lgue:              "FR",
                         societe:           "Ma Societe",
                         contexte_commande: { billing: billing_info },
                         texte_libre:       "Ton argent est notre priorite",
                         mail:              "client-name@son-domain.example.com" ) # mail: optional
```

## Development

After checking out the repo, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/conanite/monetico_payment. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MoneticoPayment project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/conanite/monetico_payment/blob/master/CODE_OF_CONDUCT.md).
