require 'http'

URL = 'https://api.openweathermap.org/data/2.5/'
API_KEY = Rails.application.credentials[:open_weather_map_api_key]

module OpenWeatherMap
  def self.city(name)
    id = Resolver.city_id(name)
    return if id.nil?

    City.parse(JSON.parse(HTTP.get("#{URL}weather", params: { id: id, appid: API_KEY })))
  end

  def self.cities(names)
    # ids = names.filter_map { |name| Resolver.city_id(name) }.join(',')

    City.parse(JSON.parse(HTTP.get("#{URL}group", params: { id: names.length, appid: API_KEY })))
  end
end
