module ExchangeProviders
  RATES_PROVIDERS = {
    "CNB" => { klass: Cnb::RatesProvider, currency: "CZK" },
  }.freeze
end
