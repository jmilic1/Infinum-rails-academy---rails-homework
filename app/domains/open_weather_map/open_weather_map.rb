require "http"

URL = "https://samples.openweathermap.org/data/2.5/weather?id=%s&appid=%s"

module OpenWeatherMap
  def self.city(name)
    id = Resolver.city_id(name)
    return if id.nil?

    data = HTTP.get(URL % [id, Rails.application.credentials[:open_weather_map_api_key]])

    City.parse(data)
  end

  def self.cities(names)
    names.map { |name| city(name) }
  end
end
