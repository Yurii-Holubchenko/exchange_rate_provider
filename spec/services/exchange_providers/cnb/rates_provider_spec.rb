describe ExchangeProviders::Cnb::RatesProvider do
  let(:source_currency) { "CZK" }
  let(:target_currency) { "USD" }
  let(:rates_provider) { described_class.new(source_currency, target_currency) }
  let(:fixed_rates_provider) { instance_double(ExchangeProviders::Cnb::FixedRatesProvider) }
  let(:expected_rates) { { "USD" => 22.5, "EUR" => 25.3 } }

  describe "#fixed_rates" do
    subject(:fixed_rates) { rates_provider.fixed_rates }

    before do
      allow(ExchangeProviders::Cnb::FixedRatesProvider).to(
        receive(:new).with(target_currency).and_return(fixed_rates_provider)
      )
      allow(fixed_rates_provider).to receive(:call).and_return(expected_rates)
    end

    it do
      expect(ExchangeProviders::Cnb::FixedRatesProvider).to receive(:new).with(target_currency).once
      fixed_rates
    end

    it do
      expect(fixed_rates_provider).to receive(:call).once
      fixed_rates
    end

    it { expect(fixed_rates).to eq(expected_rates) }
  end
end
