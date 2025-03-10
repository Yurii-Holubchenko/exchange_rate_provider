module ExchangeProviders
  class ProviderBase
    # List of required methods for each provider

    def fixed_rates
      raise NotImplementedError
    end
  end
end
