URL = 'https://api.openweathermap.org/data/2.5/'

module OpenWeatherMap
  API_KEY = Rails.application.credentials[:open_weather_map_api_key]

  def self.get_json(id, extension)
    HTTP.get(URL + extension, params: { id: id, appid: API_KEY })
  end

  def self.get_weather_data(id)
    JSON.parse(get_json(id, 'weather'))
  end

  def self.get_group_data(ids)
    JSON.parse(get_json(ids, 'group'))
  end

  def self.get_city(id)
    City.parse(get_weather_data(id))
  end

  def self.city(name)
    id = OpenWeatherMap::Resolver.city_id(name)
    return if id.nil?

    City.parse(get_weather_data(id))
  end

  def self.cities(names)
    ids = names.filter_map { |name| OpenWeatherMap::Resolver.city_id(name) }.join(',')

    get_group_data(ids)['list'].map { |entry| City.parse(entry) }
  end
end
