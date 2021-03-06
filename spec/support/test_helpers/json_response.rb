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
      api_headers.merge('X_API_SERIALIZER_ROOT': value)
    end

    def auth_headers(user)
      api_headers.merge('Authorization': user.token)
    end
  end
end
