RSpec.describe OpenWeatherMap::Resolver do
  it 'returns id of city' do
    expect(described_class.city_id('Luxembourg')).not_to eq(nil)
  end

  it 'returns nil for a nonexistent city' do
    expect(described_class.city_id('a')).to eq(nil)
  end
end
