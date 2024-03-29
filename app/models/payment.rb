class Payment < ApplicationRecord
  PAYMENT_ENABLED = true
  belongs_to :user

  mount_uploader :document, FileUploader

  COUNTRIES = [
    "Afghanistan",
"Albania",
"Algeria",
"Angola",
"Argentina","Armenia","Azerbaijan","Bangladesh","Barbados","Belize","Benin","Bhutan","Bolivia","Bosnia and Herzegovina","Botswana","Brazil","Burkina Faso","Burundi","Cabo Verde","Cambodia","Cameroon","Central African Republic","Chad","Chile",
"Colombia",
"Comoros",
"Cook Islands",
"Costa Rica",
"Côte d'Ivoire",
"Cuba",
"Korea, Democratic People's Republic of",
"Congo, The Democratic Republic of the",
"Djibouti",
"Dominica",
"Dominican Republic",
"Ecuador",
"El Salvador",
"Equatorial Guinea",
"Eritrea",
"Eswatini",
"Ethiopia",
"Fiji",
"Gabon",
"Gambia",
"Georgia",
"Ghana",
"Grenada",
"Guatemala",
"Guinea",
"Guinea-Bissau",
"Guyana",
"Haiti",
"Honduras",
"India",
"Indonesia",
"Iran, Islamic Republic of",
"Iraq",
"Jamaica",
"Jordan",
"Kazakhstan",
"Kenya",
"Kiribati",
"Kosovo",
"Kyrgyzstan",
"Laos",
"Lebanon",
"Lesotho",
"Liberia",
"Libya",
"Madagascar",
"Malawi",
"Malaysia",
"Maldives",
"Mali",
"Marshall Islands",
"Mauritania",
"Mauritius",
"Mexico",
"Micronesia, Federated States of",
"Moldova",
"Mongolia",
"Montenegro",
"Morocco",
"Mozambique",
"Myanmar",
"Namibia",
"Nauru",
"Nepal",
"Nicaragua",
"Niger",
"Nigeria",
"Niue",
"North Macedonia",
"Pakistan",
"Palau",
"Palestine, State of",
"Panama",
"Papua New Guinea",
"Paraguay",
"Peru",
"Philippines",
"Republic of the Congo",
"Rwanda",
"Saint Kitts and Nevis",
"Saint Lucia",
"Saint Vincent and the Grenadines",
"Samoa",
"San Marino",
"Sao Tome and Principe",
"Senegal",
"Serbia",
"Sierra Leone",
"Solomon Islands",
"Somalia",
"South Africa",
"South Sudan",
"Sri Lanka",
"Sudan",
"Suriname",
"Syrian Arab Republic",
"Tajikistan",
"Tanzania",
"Thailand",
"Timor-Leste",
"Togo",
"Tonga",
"Trinidad and Tobago",
"Tunisia",
"Turkmenistan",
"Tuvalu",
"Uganda",
"Ukraine",
"Uruguay",
"Uzbekistan",
"Vanuatu",
"Venezuela",
"Vietnam",
"Yemen",
"Zambia",
"Zimbabwe"
]

  def country_name
   c = ISO3166::Country[self.country]
   return c.translations[I18n.locale.to_s] || c.name
 end

end
