require 'countries'

ISO3166::Data.register(
  alpha2: 'KSO',
  name: 'Kosovo',
  translations: {
    'en' => 'Kosovo',
    'de' => 'Kosovo',
    'fr' => 'Kosovo'
  }
)

ISO3166::Country.new('KSO').name == 'Kosovo'
