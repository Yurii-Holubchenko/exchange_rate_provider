class ExchangeRatesController < ApplicationController
  # Get exchange rates for Provider
  #
  # *Params*(all params case sensitive):
  #
  # \:provider_name[String](*required*) - bank abbreviation. *Ex.:* "CNB".
  #
  # \:source_currency[String](*required*) - currency code. *Ex.:* "CZK".
  #
  # \:target_currency[String](*optional*) - currency_code OR list of currency codes with "/" separator. *Ex.:* "USD/EUR".
  #
  # Return: [JSON]
  def index
    params_validation = ExchangeProviders::ParamsValidator.new(permitted_params).call

    if params_validation.valid?
      exchange_provider = ExchangeProviders::Provider.new(
        provider_name: permitted_params[:provider_name],
        source_currency: permitted_params[:source_currency],
        target_currency: permitted_params[:target_currency]
      ).provider

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
