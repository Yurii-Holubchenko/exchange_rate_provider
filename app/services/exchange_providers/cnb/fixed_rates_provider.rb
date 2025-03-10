module ExchangeProviders
  module Cnb
    class FixedRatesProvider
      def initialize(target_currency)
        @url = "https://api.cnb.cz/cnbapi/exrates/daily?date=#{Date.today}&lang=EN"
        @target_currency = target_currency
      end

      def call
        if response.success?
          rates = JSON.parse(response.body)["rates"]

          # Convert to view {<currency_code> => <rate>, ...} for easier searching:
          # {"USD" => 25, ...}
          rates_hash = rates.each_with_object({}) do |current, result|
            result[current["currencyCode"]] = current["rate"]
          end

          filtered_rates = rates_hash.slice(*target_currency)

          [200, filtered_rates]
        else
          handle_error(response)
        end
      rescue
        [500, "Internal Server Error"]
      end

      private

      attr_reader :url, :target_currency

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
