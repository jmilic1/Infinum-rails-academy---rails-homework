module OpenWeatherMap
  class Resolver
    def self.city_id(name)
      data = JSON.parse(File.read(File.expand_path("city.list.json", __dir__)))
      entry = data.find { |element| element["name"] == name }

      return if entry.nil?
      entry
    end
  end
end
