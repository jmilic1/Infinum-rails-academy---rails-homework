NEARBY_DISTANCE = 5

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

    def nearby(count: 5) # rubocop:disable Metrics/AbcSize
      data = JSON.parse(File.read(File.expand_path('city.list.json', __dir__)))

      data.select do |element|
        other_lat = element['coord']['lat']
        other_lon = element['coord']['lon']

        Math.sqrt((lat - other_lat)**2 + (lon - other_lon)**2) < NEARBY_DISTANCE
      end[0, count]
    end

    def coldest_nearby
      arguments = [6]
      nearby(*arguments).min
    end
  end
end
