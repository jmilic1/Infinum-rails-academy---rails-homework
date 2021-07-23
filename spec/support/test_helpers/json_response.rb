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
      { 'X_API_SERIALIZER': 'json_api' }
    end

    def root_headers(value)
      {
        'X_API_SERIALIZER_ROOT': value
      }
    end

    def auth_headers(token)
      api_headers.merge('Authorization': token)
    end
  end
end
