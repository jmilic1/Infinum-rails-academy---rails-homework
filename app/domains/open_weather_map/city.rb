NEARBY_DISTANCE = 5

URL = 'https://api.openweathermap.org/geo/1.0/direct?q=%s&limit=%d&appid=%s'

module OpenWeatherMap
  class City
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
      # rubocop:disable Layout/LineLength
      data = JSON.parse(HTTP.get(format(URL, @name, count, Rails.application.credentials[:open_weather_map_api_key])))
      # rubocop:enable Layout/LineLength

      data.map { |entry| OpenWeatherMap.city(entry['name']) }
    end

    def coldest_nearby
      arguments = [6]
      nearby(*arguments).min
    end
  end
end
