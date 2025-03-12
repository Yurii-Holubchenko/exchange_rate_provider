describe ExchangeProviders::ParamsValidator do
  describe "#call" do
    let(:validator) { described_class.new({}) }

    it { expect(validator.call).to eq(validator) }
  end

  describe "#valid?" do
    let(:validator) { described_class.new(params) }

    before do
      validator.call
    end

    context "when all validations pass" do
      let(:params) do
        {
          provider_name: "CNB",
          source_currency: "CZK"
        }
      end

      it { expect(validator.valid?).to be_truthy }
    end

    context "when validations fail" do
      let(:params) do
        {
          provider_name: "GNB",
          source_currency: "",
        }
      end

      it { expect(validator.valid?).to be_falsy }
    end
  end

  describe ":provider_name validations" do
    let(:validator) { described_class.new(params).call }

    context "when :provider_name is valid" do
      let(:params) do
        {
          provider_name: "CNB",
          source_currency: "CZK"
        }
      end

      it { expect(validator.errors).to be_empty }
    end

    context "when :provider_name is blank" do
      let(:params) do
        {
          provider_name: "",
          source_currency: "CZK"
        }
      end

      it { expect(validator.errors).to include("Provider name can't be blank") }
    end

    context "when :provider_name is nil" do
      let(:params) do
        {
          provider_name: nil,
          source_currency: "CZK"
        }
      end

      it { expect(validator.errors).to include("Provider name can't be blank") }
    end

    context "when :provider_name doesn't exist in the list of available providers" do
      let(:params) do
        {
          provider_name: "GNB",
          source_currency: "CZK"
        }
      end

      it { expect(validator.errors).to include("Provider GNB is not supported") }
    end
  end

  describe ":source_currency validations" do
    let(:validator) { described_class.new(params).call }

    context "when :source_currency is valid" do
      let(:params) do
        {
          provider_name: "CNB",
          source_currency: "CZK"
        }
      end

      it { expect(validator.errors).to be_empty }
    end

    context "when source_currency is blank" do
      let(:params) do
        {
          provider_name: "CNB",
          source_currency: ""
        }
      end

      it { expect(validator.errors).to include("Source currency can't be blank") }
    end

    context "when source_currency is nil" do
      let(:params) do
        {
          provider_name: "CNB",
          source_currency: nil
        }
      end

      it { expect(validator.errors).to include("Source currency can't be blank") }
    end
  end
end
