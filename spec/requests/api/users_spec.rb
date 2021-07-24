RSpec.describe 'users API', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /users' do
    it 'successfully returns a list of users' do
      setup_index

      get '/api/users'

      expect(response).to have_http_status(:ok)
      expect(json_body['users'].length).to equal(3)
    end

    it 'returns a list of users without root' do
      setup_index

      get '/api/users',
          headers: root_headers('0')

      expect(response).to have_http_status(:ok)
      expect(json_body.length).to equal(3)
    end
  end

  describe 'GET /users/:id' do
    it 'returns a single user' do
      user = setup_show

      get "/api/users/#{user.id}"

      verify_show
    end

    it 'returns a single user serialized by json_api' do
      user = setup_show

      get "/api/users/#{user.id}",
          headers: jsonapi_headers

      verify_show
    end
  end

  describe 'POST /users' do
    context 'when params are valid' do
      let(:valid_params) do
        { first_name: 'Aragorn',
          email: 'aragorn.elessar@middle.earth' }
      end

      it 'creates a user' do
        post_new(valid_params)

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
        post_new(invalid_params)

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('first_name', 'email')
        expect(Booking.count).to eq(0)
      end
    end
  end

  describe 'updating users' do
    let(:old_name) { 'Aragorn' }
    let(:email) { 'aragorn.elessar@middle.earth' }
    let(:new_name) { 'Legolas' }
    let(:update_params) { { first_name: new_name } }
    let(:user) { create(:user, first_name: old_name, email: email) }

    it 'sends PUT /users/:id request' do
      put "/api/users/#{user.id}",
          params: { user: update_params }.to_json,
          headers: api_headers

      verify_update(User.find(user.id), new_name, email)
    end

    it 'sends PATCH /users/:id request' do
      patch "/api/users/#{user.id}",
            params: { user: update_params }.to_json,
            headers: api_headers

      verify_update(User.find(user.id), new_name, email)
    end
  end

  describe 'DELETE /users/:id' do
    it 'deletes a user' do
      user = create(:user)

      delete "/api/users/#{user.id}"

      expect(response).to have_http_status(:no_content)
      expect(User.all.length).to eq(0)
    end
  end

  def post_new(user_params)
    post  '/api/users',
          params: { user: user_params }.to_json,
          headers: api_headers
  end

  def setup_show
    create(:user)
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
end
