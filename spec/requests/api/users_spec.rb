RSpec.describe 'users API', type: :request do
  include TestHelpers::JsonResponse

  let!(:users) { FactoryBot.create_list(:user, 3) }

  describe 'GET /users' do
    it 'successfully returns a list of users' do
      get '/api/users'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /users/:id' do
    it 'returns a single user' do
      get "/api/users/#{users.first.id}"
      json_body = JSON.parse(response.body)
      expect(json_body['user']).to include('first_name')
    end
  end

  describe 'GET /users/:id/edit' do
    it 'returns a single user' do
      get "/api/users/#{users.first.id}/edit"
      json_body = JSON.parse(response.body)
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

  describe 'GET /users/new' do
    it 'returns an empty user that does not exist in database' do
      get '/api/users/new'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT /users/:id' do
    it 'updates a user' do
      id = post_new_id

      put "/api/users/#{id}",
          params: { user: { first_name: 'Ime' } }.to_json,
          headers: api_headers

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'PATCH /users/:id' do
    it 'updates a user' do
      id = post_new_id

      patch "/api/users/#{id}",
            params: { user: { first_name: 'Ime' } }.to_json,
            headers: api_headers

      expect(response).to have_http_status(:no_content)
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
