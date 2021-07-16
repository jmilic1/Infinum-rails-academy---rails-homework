module OpenWeatherMap
  module Resolver
    def self.file_path
      File.expand_path('city_list.json', __dir__)
    end

    def self.file
      File.read(file_path)
    end

    def self.parsed_data(json)
      JSON.parse(json)
    end

    def self.city_id(name)
      parsed_data(file).find { |element| element['name'] == name }&.dig('id')
    end
  end
end
