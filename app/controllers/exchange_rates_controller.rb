class ExchangeRatesController < ApplicationController
  # Get exchange rates for Provider
  #
  # @param [String] provider_name bank abbreviation(case insensitive). *Ex.:* "CNB" OR "cnb".`
  #
  # @param [String] source_currency - currency code. *Ex.:* "CZK".
  #
  # @param [String] target_currency - currency_code OR list of currency codes with "/" separator. *Ex.:* "USD/EUR".
  #
  # @return [JSON]
  def index
    params_validation = ParamsValidator.new(permitted_params).call

    if params_validation.valid?
      exchange_provider = ExchangeProviders::Provider.new(**permitted_params)
      status, result = exchange_provider.fixed_rates

      render json: { result: result }, status: status
    else
      render json: { result: params_validation.errors }, status: 422
    end
  end

  private

  def permitted_params
    params.permit(:provider_name, :source_currency, :target_currency)
  end
end
