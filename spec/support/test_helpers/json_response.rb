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
        'X_API_SERIALIZER': 'json_api'
      }
    end

    def root_headers_one
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X_API_SERIALIZER_ROOT': '1'
      }
    end

    def root_headers_zero
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X_API_SERIALIZER_ROOT': '0'
      }
    end
  end
end
