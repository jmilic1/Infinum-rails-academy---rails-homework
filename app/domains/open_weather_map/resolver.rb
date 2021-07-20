module OpenWeatherMap
  module Resolver
    def self.city_id(name)
      parsed_data(file).find { |element| element['name'] == name }&.dig('id')
    end

    def self.parsed_data(json)
      JSON.parse(json)
    end

    def self.file
      File.read(file_path)
    end

    def self.file_path
      File.expand_path('city_list.json', __dir__)
    end
  end
end
