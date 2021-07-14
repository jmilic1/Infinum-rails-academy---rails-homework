CITY_ID = 42
LAT = 250
LON = 365
NAME = 'Atlantis'
TEMP_K = 300
ZERO_CELSIUS_TO_KELVIN = 273.15
DATA = {
  'coord' => {
    'lon' => 145.77,
    'lat' => -16.92
  },
  'weather' => [
    {
      'id' => 802,
      'main' => 'Clouds',
      'description' => 'scattered clouds',
      'icon' => '03n'
    }
  ],
  'base' => 'stations',
  'main' => {
    'temp' => 300.15,
    'pressure' => 1007,
    'humidity' => 74,
    'temp_min' => 300.15,
    'temp_max' => 300.15
  },
  'visibility' => 10_000,
  'wind' => {
    'speed' => 3.6,
    'deg' => 160
  },
  'clouds' => {
    'all' => 40
  },
  'dt' => 1_485_790_200,
  'sys' => {
    'type' => 1,
    'id' => 8166,
    'message' => 0.2064,
    'country' => 'AU',
    'sunrise' => 1_485_720_272,
    'sunset' => 1_485_766_550
  },
  'id' => 2_172_797,
  'name' => 'Cairns',
  'cod' => 200
}

RSpec.describe OpenWeatherMap::City do
  let(:city) { described_class.new(id: CITY_ID, lat: LAT, lon: LON, name: NAME, temp_k: TEMP_K) }

  let(:parsed) { described_class.parse(DATA) }

  it 'returns id of city' do
    expect(city.id).to eq(CITY_ID)
  end

  it 'returns lat of city' do
    expect(city.lat).to eq(LAT)
  end

  it 'returns lon of city' do
    expect(city.lon).to eq(LON)
  end

  it 'returns name of city' do
    expect(city.name).to eq(NAME)
  end

  it 'returns temp of city' do
    expect(city.temp).to eq(TEMP_K - ZERO_CELSIUS_TO_KELVIN)
  end

  it 'compares city with lower temperature to city with higher temperature' do
    receiver = described_class.new(id: 0, lat: 0, lon: 0, name: 'A', temp_k: 0)
    other = described_class.new(id: 1, lat: 1, lon: 1, name: 'A', temp_k: 100)

    expect(receiver <=> other).to be < 0
  end

  it 'compares city with alphabetically lesser name to city with same temperature and alphabetically greater name' do
    receiver = described_class.new(id: 0, lat: 0, lon: 0, name: 'A', temp_k: 0)
    other = described_class.new(id: 1, lat: 1, lon: 1, name: 'B', temp_k: 0)

    expect(receiver <=> other).to be < 0
  end

  it 'compares cities with same name and temperature' do
    receiver = described_class.new(id: 0, lat: 0, lon: 0, name: 'A', temp_k: 0)
    other = described_class.new(id: 1, lat: 1, lon: 1, name: 'A', temp_k: 0)

    expect(receiver <=> other).to be 0
  end

  it 'compares city with greater temperature to city with lower temperature' do
    receiver = described_class.new(id: 0, lat: 0, lon: 0, name: 'A', temp_k: 100)
    other = described_class.new(id: 1, lat: 1, lon: 1, name: 'A', temp_k: 0)

    expect(receiver <=> other).to be > 0
  end

  it 'compares city with alphabetically greater name to city with same temperature and alphabetically lesser name' do
    receiver = described_class.new(id: 0, lat: 0, lon: 0, name: 'B', temp_k: 0)
    other = described_class.new(id: 1, lat: 1, lon: 1, name: 'A', temp_k: 0)

    expect(receiver <=> other).to be > 0
  end


  it 'returns id of parsed city' do
    expect(parsed.id).to eq(DATA['id'])
  end

  it 'returns lat of parsed city' do
    expect(parsed.lat).to eq(DATA['coord']['lat'])
  end

  it 'returns lon of parsed city' do
    expect(parsed.lon).to eq(DATA['coord']['lon'])
  end

  it 'returns name of parsed city' do
    expect(parsed.name).to eq(DATA['name'])
  end

  it 'returns temp of parsed city' do
    expect(parsed.temp).to eq(DATA['main']['temp'] - ZERO_CELSIUS_TO_KELVIN)
  end
end
