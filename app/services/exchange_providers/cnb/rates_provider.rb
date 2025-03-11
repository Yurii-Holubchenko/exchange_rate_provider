module ExchangeProviders
  module Cnb
    class RatesProvider < ProviderBase
      def initialize(source_currency:, target_currency:)
        @source_currency = source_currency
        @target_currency = target_currency
      end

      def fixed_rates
        FixedRatesProvider.new(
          source_currency: source_currency,
          target_currency: target_currency
        ).call
      end

      # other possible options which return exchange rates

      private

      attr_reader :source_currency, :target_currency
    end
  end
end
