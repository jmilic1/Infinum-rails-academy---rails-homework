RSpec.describe Flight do
  describe 'name presence' do
    subject { described_class.new(name: 'Jura', base_price: 20, arrives_at: Time.now.to_i, departs_at: Time.now.to_i) }

    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'uniqueness' do
    subject { described_class.new(name: 'Juraj', base_price: 20, arrives_at: Time.now.to_i, departs_at: Time.now.to_i) }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:company_id) }
  end
end
