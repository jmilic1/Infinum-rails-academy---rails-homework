Rspec.describe OpenWeatherMap.Resolver do
  it 'returns id of city' do
    expect(OpenWeatherMap.Resolver.city_id('Luxembourg')).not_to eq(nil)
  end

  it 'returns nil of nonexistent city' do
    expect(OpenWeatherMap.Resolver.city_id('a')).to eq(nil)
  end
end