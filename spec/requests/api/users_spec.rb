RSpec.describe 'users API', type: :request do
  include TestHelpers::JsonResponse
  let(:admin_token) { 'admin-token' }
  let(:public_token) { 'public-token' }

  before do
    create(:user, token: admin_token, role: 'admin')
    create(:user, token: public_token, role: 'public')
  end

  describe 'GET /users' do
    before { create_list(:user, 3) }

    it 'successfully returns a list of users' do
      get '/api/users',
          headers: auth_headers(admin_token)

      expect(response).to have_http_status(:ok)
      expect(json_body['users'].length).to equal(5)
    end

    it 'returns a list of users without root' do
      get '/api/users',
          headers: root_headers('0').merge(auth_headers(admin_token))

      expect(response).to have_http_status(:ok)
      expect(json_body.length).to equal(5)
    end
  end

  describe 'GET /users/:id' do
    let(:user) { create(:user) }

    it 'returns a single user' do
      get "/api/users/#{user.id}",
          headers: auth_headers(admin_token)

      expect(json_body['user']).to include('first_name')
    end

    it 'returns a single user serialized by json_api' do
      get "/api/users/#{user.id}",
          headers: jsonapi_headers.merge(auth_headers(admin_token))

      expect(json_body['user']).to include('first_name')
    end
  end

  describe 'POST /users' do
    context 'when params are valid' do
      it 'creates a user' do
        first_name = 'FirstName'
        email = 'first.name@backend.com'
        password = 'password'

        id = post_new_id(first_name, email, password)

        get "/api/users/#{id}",
            headers: auth_headers(admin_token)

        expect(json_body['user']).to include('id' => id,
                                             'first_name' => first_name,
                                             'email' => email)
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

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe 'updating users' do
    let(:old_name) { 'Aragorn' }
    let(:email) { 'ime.prezime@backend.com' }
    let(:password) { 'password' }
    let(:new_name) { 'Legolas' }

    it 'sends PUT /users/:id request' do
      id = post_new_id(old_name, email, password)

      put "/api/users/#{id}",
          params: { user: { first_name: new_name } }.to_json,
          headers: auth_headers(admin_token)

      expect(response).to have_http_status(:ok)
      expect(json_body['user']).to include('first_name' => new_name, 'email' => email)
    end

    it 'returns 400 Bad Request' do
      id = post_new_id(old_name, email, password)

      put "/api/users/#{id}",
          params: { user: { first_name: 'Ime', password: '' } }.to_json,
          headers: auth_headers(admin_token)

      expect(response).to have_http_status(:bad_request)
    end

    it 'sends PATCH /users/:id request' do
      id = post_new_id(old_name, email, password)

      patch "/api/users/#{id}",
            params: { user: { first_name: new_name } }.to_json,
            headers: auth_headers(admin_token)

      expect(response).to have_http_status(:ok)
      expect(json_body['user']).to include('first_name' => new_name, 'email' => email)
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  describe 'DELETE /users/:id' do
    it 'deletes a user' do
      id = post_new_id('Ime', 'ime.prezime@backend.com', 'password')

      delete "/api/users/#{id}",
             headers: auth_headers(admin_token)

      expect(response).to have_http_status(:no_content)

      get "/api/users/#{id}"

      expect(response).to have_http_status(:not_found)
    end
  end

  def post_new_id(first_name, email, password)
    post  '/api/users',
          params: { user: { first_name: first_name, email: email, password: password } }.to_json,
          headers: auth_headers(admin_token)

    json_body['user']['id']
  end
end
