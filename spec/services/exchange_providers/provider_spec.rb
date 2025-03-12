describe ExchangeProviders::Provider do
  subject { described_class.new(**params) }

  let(:source_currency) { "CZK" }
  let(:target_currency) { "USD/EUR" }
  let(:provider_name) { "CNB" }
  let(:provider_instance) { instance_double(ExchangeProviders::Cnb::RatesProvider) }

  before do
    allow(ExchangeProviders::Cnb::RatesProvider).to receive(:new).and_return(provider_instance)
  end

  describe "#initialize" do
    let(:params) do
      {
        provider_name: provider_name,
        source_currency: source_currency,
        target_currency: target_currency
      }
    end

    context "with initialized provider" do
      it { expect(subject.provider).to eq(provider_instance) }
    end

    context "with :target_currency is provided" do
      it do
        expect(ExchangeProviders::Cnb::RatesProvider).to receive(:new).with(
          source_currency: source_currency,
          target_currency: ["USD", "EUR"]
        )
        subject
      end
    end

    context "when :target_currency is nil" do
      let(:params) do
        {
          provider_name: provider_name,
          source_currency: source_currency
        }
      end

      it do
        expect(ExchangeProviders::Cnb::RatesProvider).to receive(:new).with(
          source_currency: source_currency,
          target_currency: []
        )
        subject
      end
    end

    context "when :target_currency is empty string" do
      let(:params) do
        {
          provider_name: provider_name,
          source_currency: source_currency,
          target_currency: ""
        }
      end

      it do
        expect(ExchangeProviders::Cnb::RatesProvider).to receive(:new).with(
          source_currency: source_currency,
          target_currency: []
        )
        subject
      end
    end
  end
end
