module ExchangeProviders
  module Cnb
    class FixedRatesProvider
      def initialize(source_currency:, target_currency:)
        @url = "https://api.cnb.cz/cnbapi/exrates/daily?date=#{Date.today}&lang=EN"
        @target_currency = target_currency
        @source_currency = source_currency
      end

      def call
        if source_currency != RATES_PROVIDERS["CNB"][:currency]
          return [400, "Source currency #{source_currency} is not supported"]
        end

        if response.success?
          rates = JSON.parse(response.body)["rates"]

          # Convert to view {<currency_code> => <rate>, ...} for easier searching:
          # {"USD" => 25, ...}
          rates_hash = rates.each_with_object({}) do |current, result|
            current_rate = BigDecimal(current["rate"].to_s) / BigDecimal(current["amount"].to_s)
            result[current["currencyCode"]] = current_rate.to_f
          end

          filtered_rates = target_currency.empty? ? rates_hash : rates_hash.slice(*target_currency)

          [200, filtered_rates]
        else
          handle_error(response)
        end
      rescue
        [500, "Internal Server Error"]
      end

      private

      attr_reader :url, :source_currency, :target_currency

      def response
        Faraday.get(url)
      end

      def handle_error(response)
        # Rewrite errors to something human readable
        case response.status
        when 400
          [400, "Bad Request"]
        when 500
          [500, "Internal Server Error"]
        end
      end
    end
  end
end
