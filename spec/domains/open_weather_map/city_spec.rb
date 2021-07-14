CITY_ID = 42
LAT = 250
LON = 365
NAME = "Atlantis"
TEMP_K = 300
ZERO_CELSIUS_TO_KELVIN = 273.15

RSpec.describe OpenWeatherMap::City do

  let(:city) { OpenWeatherMap::City.new(id: CITY_ID, lat: LAT, lon: LON, name: NAME, temp_k: TEMP_K) }

  it "returns id of city" do
    expect(city.id).to eq(CITY_ID)
  end

  it "returns lat of city" do
    expect(city.lat).to eq(LAT)
  end

  it "returns lon of city" do
    expect(city.lon).to eq(LON)
  end

  it "returns name of city" do
    expect(city.name).to eq(NAME)
  end

  it "returns temp of city" do
    expect(city.temp).to eq(TEMP_K - ZERO_CELSIUS_TO_KELVIN)
  end

  it "compares city with lower temperature to city with higher temperature" do
    receiver = OpenWeatherMap::City.new(id: 0, lat: 0, lon: 0, name: "A", temp_k: 0)
    other = OpenWeatherMap::City.new(id: 1, lat: 1, lon: 1, name: "A", temp_k: 100)

    expect(receiver <=> other).to be < 0
  end

  it "compares city with alphabetically lesser name to city with same temperature and alphabetically greater name" do
    receiver = OpenWeatherMap::City.new(id: 0, lat: 0, lon: 0, name: "A", temp_k: 0)
    other = OpenWeatherMap::City.new(id: 1, lat: 1, lon: 1, name: "B", temp_k: 0)

    expect(receiver <=> other).to be < 0
  end

  it "compares cities with same name and temperature" do
    receiver = OpenWeatherMap::City.new(id: 0, lat: 0, lon: 0, name: "A", temp_k: 0)
    other = OpenWeatherMap::City.new(id: 1, lat: 1, lon: 1, name: "A", temp_k: 0)

    expect(receiver <=> other).to be 0
  end

  it "compares city with greater temperature to city with lower temperature" do
    receiver = OpenWeatherMap::City.new(id: 0, lat: 0, lon: 0, name: "A", temp_k: 100)
    other = OpenWeatherMap::City.new(id: 1, lat: 1, lon: 1, name: "A", temp_k: 0)

    expect(receiver <=> other).to be > 0
  end

  it "compares city with alphabetically greater name to city with same temperature and alphabetically lesser name" do
    receiver = OpenWeatherMap::City.new(id: 0, lat: 0, lon: 0, name: "B", temp_k: 0)
    other = OpenWeatherMap::City.new(id: 1, lat: 1, lon: 1, name: "A", temp_k: 0)

    expect(receiver <=> other).to be > 0
  end
end
