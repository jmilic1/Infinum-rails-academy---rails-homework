RSpec.describe 'users API', type: :request do
  include TestHelpers::JsonResponse
  let(:admin_token) { 'admin-token' }
  let(:public_token) { 'public-token' }

  before do
    create(:user, token: admin_token, role: 'admin')
    create(:user, token: public_token, role: 'public')
  end

  describe 'GET /users' do
    it 'successfully returns a list of users' do
      setup_index

      get '/api/users',
          headers: auth_headers(admin_token)

      expect(response).to have_http_status(:ok)
      expect(json_body['users'].length).to equal(5)
    end

    it 'returns a list of users without root' do
      setup_index

      get '/api/users',
          headers: root_headers('0').merge(auth_headers(admin_token))

      expect(response).to have_http_status(:ok)
      expect(json_body.length).to equal(5)
    end
  end

  describe 'GET /users/:id' do
    it 'returns a single user' do
      user = setup_show

      get "/api/users/#{user.id}",
          headers: auth_headers(admin_token)

      verify_show
    end

    it 'returns a single user serialized by json_api' do
      user = setup_show

      get "/api/users/#{user.id}",
          headers: jsonapi_headers.merge(auth_headers(admin_token))

      verify_show
    end
  end

  describe 'POST /users' do
    context 'when params are valid' do
      let(:valid_params) do
        { first_name: 'Aragorn',
          email: 'aragorn.elessar@middle.earth',
          password: 'IsildursHeir' }
      end

      it 'creates a user' do
        post_new(valid_params, admin_token)

        expect(response).to have_http_status(:created)
        expect(User.count).to eq(1)
        user = User.all.first
        expect(user.first_name).to eq(valid_params[:first_name])
        expect(user.last_name).to eq(valid_params[:last_name])
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { first_name: '' }
      end

      it 'returns 400 Bad Request' do
        post_new(invalid_params, admin_token)

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('first_name', 'email')
        expect(Booking.count).to eq(0)
      end
    end
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe 'updating users' do
    let(:old_name) { 'Aragorn' }
    let(:email) { 'aragorn.elessar@middle.earth' }
    let(:password) { 'password' }
    let(:new_name) { 'Legolas' }
    let(:update_params) { { first_name: new_name } }
    let(:user) { create(:user, first_name: old_name, email: email) }

    it 'sends PUT /users/:id request' do
      put "/api/users/#{user.id}",
          params: { user: update_params }.to_json,
          headers: auth_headers(admin_token)

      verify_update(User.find(user.id), new_name, email)
    end

    it 'returns 400 Bad Request' do
      put "/api/users/#{user.id}",
          params: { user: { first_name: 'Ime', password: '' } }.to_json,
          headers: auth_headers(admin_token)

      expect(response).to have_http_status(:bad_request)
    end

    it 'sends PATCH /users/:id request' do
      patch "/api/users/#{user.id}",
            params: { user: update_params }.to_json,
            headers: auth_headers(admin_token)

      verify_update(User.find(user.id), new_name, email)
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  describe 'DELETE /users/:id' do
    it 'deletes a user' do
      user = create(:user)

      delete "/api/users/#{user.id}",
             headers: auth_headers(admin_token)

      expect(response).to have_http_status(:no_content)
      expect(User.all.length).to eq(0)
    end
  end

  def post_new(user_params, token)
    post  '/api/users',
          params: { user: user_params }.to_json,
          headers: auth_headers(token)
  end

  def verify_show
    expect(json_body['user']).to include('first_name', 'last_name', 'email')
  end

  def setup_index
    create_list(:user, 3)
  end

  def verify_update(user, new_name, email)
    expect(response).to have_http_status(:ok)
    expect(user.first_name).to eq(new_name)
    expect(user.email).to eq(email)
  end

  def setup_show
    create(:user)
  end
end
