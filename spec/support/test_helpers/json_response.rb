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

    def root_headers_one
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x_api_serializer_root': '1'
      }
    end

    def root_headers_zero
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x_api_serializer_root': '0'
      }
    end

    def auth_headers(token)
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': token
      }
    end
  end
end
