module ExchangeProviders
  class ParamsValidator
    attr_reader :errors

    def initialize(params)
      @params = params
      @errors = []
    end

    def call
      validate_provider_name
      validate_source_currency

      self
    end

    def valid?
      @errors.empty?
    end

    private

    attr_reader :params

    def validate_provider_name
      if params[:provider_name].blank?
        @errors << "Provider name can't be blank"
      elsif RATES_PROVIDERS.keys.exclude?(params[:provider_name])
        @errors << "Provider #{params[:provider_name]} is not supported"
      end
    end

    def validate_source_currency
      if params[:source_currency].blank?
        @errors << "Source currency can't be blank"
      end
    end
  end
end
