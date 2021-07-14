require 'http'

URL = 'https://samples.openweathermap.org/data/2.5/weather?id=%s&appid=%s'

module OpenWeatherMap
  module OpenWeatherMap
    def self.city(name)
      id = Resolver.city_id(name)
      return if id.nil?

      data = JSON.parse(HTTP.get(format(URL, id,
                                        Rails.application.credentials[:open_weather_map_api_key])))

      City.parse(data)
    end

    def self.cities(names)
      names.filter_map { |name| city(name) }
    end
  end
end
