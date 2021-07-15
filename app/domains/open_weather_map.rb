require 'http'

URL = 'https://api.openweathermap.org/data/2.5/weather?id=%s&appid=%s'
URL_TEST = 'https://api.openweathermap.org/data/2.5/weather?id=%s&appid='

module OpenWeatherMap
  def self.city(name)
    id = Resolver.city_id(name)
    return if id.nil?

    # rubocop:disable Layout/LineLength
    # data = JSON.parse(HTTP.get(format(URL, id, Rails.application.credentials[:open_weather_map_api_key])))
    data = JSON.parse(HTTP.get(format(URL_TEST, id) + Rails.application.credentials[:open_weather_map_api_key]))
    # rubocop:enable Layout/LineLength

    City.parse(data)
  end

  def self.cities(names)
    names.filter_map { |name| city(name) }
  end
end
