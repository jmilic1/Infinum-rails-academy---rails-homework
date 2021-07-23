RSpec.describe 'users API', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /users' do
    before { create_list(:user, 3) }

    it 'successfully returns a list of users' do
      get '/api/users'

      expect(response).to have_http_status(:ok)
      expect(json_body['users'].length).to equal(3)
    end

    it 'returns a list of users without root' do
      get '/api/users',
          headers: root_headers('0')

      expect(response).to have_http_status(:ok)
      expect(json_body.length).to equal(3)
    end
  end

  describe 'GET /users/:id' do
    let(:user) { create(:user) }

    it 'returns a single user' do
      get "/api/users/#{user.id}"

      expect(json_body['user']).to include('first_name')
    end

    it 'returns a single user serialized by json_api' do
      get "/api/users/#{user.id}",
          headers: jsonapi_headers

      expect(json_body['user']).to include('first_name')
    end
  end

  describe 'POST /users' do
    context 'when params are valid' do
      it 'creates a user' do
        post  '/api/users',
              params: { user: { first_name: 'Ime', email: 'ime.prezime@backend.com' } }.to_json,
              headers: api_headers

        expect(json_body['user']).to include('first_name' => 'Ime')
      end

      it 'checks a user was created' do
        first_name = 'FirstName'
        email = 'first.name@backend.com'
        post  '/api/users',
              params: { user: { first_name: first_name, email: email } }.to_json,
              headers: api_headers

        id = json_body['user']['id']

        get "/api/users/#{id}"

        expect(json_body['user']).to include('id' => id,
                                             'first_name' => first_name,
                                             'email' => email)
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/users',
             params: { user: { first_name: '' } }.to_json,
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
          params: { user: { first_name: 'Ime', email: 'ime.prezime@backend.com' } }.to_json,
          headers: api_headers

    json_body['user']['id']
  end
end
