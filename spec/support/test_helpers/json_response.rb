module TestHelpers
  module JsonResponse
    def json_body
      JSON.parse(response.body)
    end

    def api_headers
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    end

    def jsonapi_headers
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x_api_serializer': 'json_api'
      }
    end
  end
end
