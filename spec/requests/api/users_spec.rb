RSpec.describe 'users API', type: :request do
  include TestHelpers::JsonResponse

  let!(:users) { create_list(:user, 3) }

  describe 'GET /users' do
    it 'successfully returns a list of users' do
      get '/api/users'

      expect(response).to have_http_status(:ok)
      expect(json_body['users'].length).to equal(3)
    end

    it 'returns a list of users without root' do
      get '/api/users',
          headers: root_headers_zero

      expect(response).to have_http_status(:ok)
      expect(json_body.length).to equal(3)
    end
  end

  describe 'GET /users/:id' do
    it 'returns a single user' do
      get "/api/users/#{users.first.id}"

      expect(json_body['user']).to include('first_name')
    end

    it 'returns a single user serialized by json_api' do
      get "/api/users/#{users.first.id}",
          headers: jsonapi_headers

      expect(json_body['user']).to include('first_name')
    end
  end

  describe 'POST /users' do
    context 'when params are valid' do
      it 'creates a user' do
        post  '/api/users',
              params: { user: { first_name: 'Ime',
                                email: 'ime.prezime@backend.com',
                                password: 'password-numero' } }.to_json,
              headers: api_headers

        expect(json_body['user']).to include('first_name' => 'Ime')
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/users',
             params: { user: { first_name: '', password: 'password' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('first_name')
      end
    end
  end

  describe 'PUT /users/:id' do
    it 'updates a user' do
      id = post_new_id

      put "/api/users/#{id}",
          params: { user: { first_name: 'Ime' } }.to_json,
          headers: api_headers

      expect(response).to have_http_status(:ok)
    end

    it 'returns 400 Bad Request' do
      id = post_new_id

      put "/api/users/#{id}",
          params: { user: { first_name: 'Ime', password: '' } }.to_json,
          headers: api_headers

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'PATCH /users/:id' do
    it 'updates a user' do
      id = post_new_id

      patch "/api/users/#{id}",
            params: { user: { first_name: 'Ime' } }.to_json,
            headers: api_headers

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE /users/:id' do
    it 'delete a user' do
      id = post_new_id

      delete "/api/users/#{id}"

      expect(response).to have_http_status(:no_content)
    end
  end

  def post_new_id
    post  '/api/users',
          params: { user: { first_name: 'Ime',
                            email: 'ime.prezime@backend.com',
                            password: 'password-numero' } }.to_json,
          headers: api_headers

    json_body['user']['id']
  end
end
