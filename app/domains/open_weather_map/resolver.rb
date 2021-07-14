module OpenWeatherMap
  class Resolver
    def self.city_id(name)
      data = JSON.parse(File.read(File.expand_path('city_ids.json', __dir__)))
      result = data.find { |element| element['name'] == name }['id']
    end
  end
  def first_module_method
  end
end
