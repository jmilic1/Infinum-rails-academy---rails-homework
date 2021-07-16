URL = 'https://api.openweathermap.org/data/2.5/'

module OpenWeatherMap
  API_KEY = Rails.application.credentials[:open_weather_map_api_key]

  def self.city(name)
    id = Resolver.city_id(name)
    return if id.nil?

    City.parse(JSON.parse(HTTP.get("#{URL}weather", params: { id: id, appid: API_KEY })))
  end

  def self.cities(names)
    ids = names.filter_map { |name| OpenWeatherMap::Resolver.city_id(name) }.join(',')

    data = JSON.parse(HTTP.get("#{URL}group", params: { id: ids, appid: API_KEY }))
    data['list'].map { |entry| City.parse(entry) }
  end
end
