require 'http'

URL = 'https://api.openweathermap.org/data/2.5/'

module OpenWeatherMap
  def self.city(name)
    id = Resolver.city_id(name)
    return if id.nil?

    # rubocop:disable Layout/LineLength
    City.parse(JSON.parse(HTTP.get("#{URL}weather", params: { id: id, appid: Rails.application.credentials[:open_weather_map_api_key] })))
    # rubocop:enable Layout/LineLength
  end

  def self.cities(names)
    names.filter_map { |name| city(name) }
  end
end