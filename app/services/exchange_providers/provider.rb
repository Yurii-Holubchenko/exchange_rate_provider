module ExchangeProviders
  class Provider
    attr_reader :provider

    def initialize(provider_name:, source_currency:, target_currency: nil)
      provider_klass = RATES_PROVIDERS[provider_name][:klass]
      target_currency = target_currency.present? ? target_currency.split("/") : []

      @provider = provider_klass.new(
        source_currency: source_currency,
        target_currency: target_currency
      )
    end
  end
end
