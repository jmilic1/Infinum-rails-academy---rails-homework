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
      lat = data.dig('coord', 'lat')
      lon = data.dig('coord', 'lon')
      temp_k = data.dig('main', 'temp')
      id = data['id']
      name = data['name']

      new(id: id, lat: lat, lon: lon, name: name, temp_k: temp_k)
    end

    def get_find_data(lat, lon, count)
      JSON.parse(
        OpenWeatherMap.send_get_request('find', { lat: lat, lon: lon, cnt: count, appid: API_KEY })
      )
    end

    def nearby(count = 5)
      get_find_data(lat, lon, count)['list'].map { |entry| OpenWeatherMap::City.parse(entry) }
    end

    def coldest_nearby(count = 5)
      arguments = [count]
      nearby(*arguments).min
    end
  end
end
