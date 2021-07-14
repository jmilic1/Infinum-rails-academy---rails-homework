class OpenWeatherMap::City
  ZERO_CELSIUS_TO_KELVIN = 273.15

  attr_reader :id, :lat, :lon, :name

  def initialize(id:, lat:, lon:, name:, temp_k:)
    @id = id
    @lat = lat
    @lon = lon
    @name = name
    @temp_k = temp_k
  end

  def temp
    @temp_k - ZERO_CELSIUS_TO_KELVIN
  end

  def <=>(other)
    comparison = temp <=> other.temp
    return comparison unless comparison == 0

    name <=> other.name
  end

  def self.parse(data)
    lat = data["coord"]["lat"]
    lon = data["coord"]["lon"]
    temp_k = data["main"]["temp"]
    id = data["id"]
    name = data["name"]

    new(id: id, lat: lat, lon: lon, name: name, temp_k: temp_k)
  end

end

