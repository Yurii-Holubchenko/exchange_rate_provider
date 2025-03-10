describe ExchangeProviders::Cnb::FixedRatesProvider do
  let(:source_currency) { "CZK" }
  let(:target_currency) { ["USD", "EUR"] }
  let(:provider) { described_class.new(source_currency: source_currency, target_currency: target_currency) }
  let(:url) { "https://api.cnb.cz/cnbapi/exrates/daily?date=#{Date.today}&lang=EN" }
  let(:successful_response) do
    instance_double(
      Faraday::Response,
      success?: true,
      body: {
        "rates" => [
          { "currencyCode" => "USD", "rate" => "25.0", "amount" => "1" },
          { "currencyCode" => "EUR", "rate" => "27.5", "amount" => "1" },
          { "currencyCode" => "GBP", "rate" => "32.0", "amount" => "1" }
        ]
      }.to_json
    )
  end

  before do
    allow(Rails.cache).to receive(:fetch).and_yield
  end

  describe "#call" do
    context "when source currency is supported" do
      before do
        allow(Faraday).to receive(:get).with(url).and_return(successful_response)
      end

      it "returns rates for specified target currencies" do
        status, rates = provider.call

        expect(status).to eq(200)
        expect(rates).to eq({ "USD" => 25.0, "EUR" => 27.5 })
      end

      context "when target_currency is empty" do
        let(:target_currency) { [] }

        it "returns all available rates" do
          status, rates = provider.call

          expect(status).to eq(200)
          expect(rates).to eq({ "USD" => 25.0, "EUR" => 27.5, "GBP" => 32.0 })
        end
      end

      context "when rate has different amount" do
        let(:successful_response) do
          instance_double(
            Faraday::Response,
            success?: true,
            body: {
              "rates" => [
                { "currencyCode" => "USD", "rate" => "25.0", "amount" => "1" },
                { "currencyCode" => "JPY", "rate" => "18.75", "amount" => "100" }
              ]
            }.to_json
          )
        end

        let(:target_currency) { ["USD", "JPY"] }

        it "calculates rate correctly based on amount" do
          status, rates = provider.call

          expect(status).to eq(200)
          expect(rates["JPY"]).to eq(0.1875) # 18.75/100
        end
      end
    end

    context "when source currency is not supported" do
      let(:source_currency) { "USD" }

      it "returns error message" do
        status, message = provider.call

        expect(status).to eq(400)
        expect(message).to eq("Source currency USD is not supported")
      end
    end

    context "when API returns an error" do
      before do
        allow(Faraday).to receive(:get).with(url).and_return(error_response)
      end

      context "with 500 error" do
        let(:error_response) { instance_double(Faraday::Response, success?: false, status: 500) }

        it do
          status, message = provider.call

          expect(status).to eq(500)
          expect(message).to eq("Internal Server Error")
        end
      end

      context "with 400 error" do
        let(:error_response) { instance_double(Faraday::Response, success?: false, status: 400) }

        it do
          status, message = provider.call

          expect(status).to eq(400)
          expect(message).to eq("Bad Request")
        end
      end
    end

    context "when an exception occurs" do
      before do
        allow(Faraday).to receive(:get).with(url).and_raise(StandardError)
      end

      it "returns a 500 error" do
        status, message = provider.call

        expect(status).to eq(500)
        expect(message).to eq("Internal Server Error")
      end
    end

    context "when caching is used" do
      it "uses Rails cache with correct expiration" do
        expect(Rails.cache).to receive(:fetch).with("cnb_fixed_exchange_rates:test", expires_in: 1.hour)
        provider.call
      end
    end
  end
end
