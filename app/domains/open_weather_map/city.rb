module OpenWeatherMap
  class City
    ZERO_CELSIUS_TO_KELVIN = 273.15

    attr_reader :id, :lat, :lon, :name, :temp_k

    def initialize(id:, lat:, lon:, name:, temp_k:)
      @id = id
      @lat = lat
      @lon = lon
      @name = name
      @temp_k = temp_k
    end

    def temp
      temp_k - ZERO_CELSIUS_TO_KELVIN
    end

    def <=>(other)
      comparison = temp <=> other.temp
      return comparison unless comparison.zero?

      name <=> other.name
    end

    def self.parse(data)
      lat = data['coord']['lat']
      lon = data['coord']['lon']
      temp_k = data['main']['temp']
      id = data['id']
      name = data['name']

      new(id: id, lat: lat, lon: lon, name: name, temp_k: temp_k)
    end

    def nearby(count = 5)
      data = JSON.parse(
        HTTP.get(
          "#{URL}find", params: { lat: lat, lon: lon, cnt: count, appid: API_KEY }
        )
      )

      data['list'].map { |entry| OpenWeatherMap::City.parse(entry) }
    end

    def coldest_nearby(count = 5)
      arguments = [count]
      nearby(*arguments).min
    end
  end
end
