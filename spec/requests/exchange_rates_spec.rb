describe "ExchangeRates", type: :request do
  describe "GET /exchange_rates" do
    let(:valid_params) do
      {
        provider_name: "CNB",
        source_currency: "CZK",
        target_currency: "USD/EUR"
      }
    end

    let(:invalid_params) do
      {
        provider_name: "",
        source_currency: "",
        target_currency: ""
      }
    end
    let(:body) { JSON.parse(response.body) }
    let(:provider) { instance_double(ExchangeProviders::Provider, provider: rates_provider) }
    let(:rates_provider) { instance_double(ExchangeProviders::Cnb::RatesProvider) }

    context "with valid parameters" do
      before do
        allow(ExchangeProviders::Provider).to(receive(:new).with(valid_params).and_return(provider))
        allow(rates_provider).to receive(:fixed_rates).and_return([200, { "USD" => 0.045, "EUR" => 0.042 }])

        get exchange_rates_path, params: valid_params
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(body).to eq("result" => { "USD" => 0.045, "EUR" => 0.042 }) }
    end

    context "with invalid parameters" do
      before do
        get exchange_rates_path, params: invalid_params
      end

      it { expect(response).to have_http_status(:unprocessable_content) }
      it { expect(body).to eq("result" => ["Provider name can't be blank", "Source currency can't be blank"]) }
    end

    context "with missing optional parameter target_currency" do
      let(:params_without_target_currency) do
        {
          provider_name: "CNB",
          source_currency: "CZK",
          target_currency: ""
        }
      end

      before do
        allow(ExchangeProviders::Provider).to(receive(:new).with(params_without_target_currency).and_return(provider))
        allow(rates_provider).to receive(:fixed_rates).and_return([200, { "USD" => 0.045, "GBP" => 0.038 }])

        get exchange_rates_path, params: params_without_target_currency
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(body).to eq("result" => { "USD" => 0.045, "GBP" => 0.038 }) }
    end
  end
end
