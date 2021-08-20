RSpec.describe 'Users API', type: :request do
  include TestHelpers::JsonResponse
  let!(:admin) { create(:user, first_name: 'aragorn', token: 'admin-token', role: 'admin') }
  let!(:public) { create(:user, last_name: 'ARAGORN', token: 'public-token') }

  describe 'GET /users' do
    before do
      create(:user, email: 'aragorn.dunedain@middle.earth')
      create_list(:user, 3)
    end

    it 'returns 401 unauthorized if unauthenticated user indexes users' do
      get '/api/users'

      expect(response).to have_http_status(:unauthorized)
      expect(json_body['errors']).to include('token')
    end

    context 'when admin indexes users' do
      it 'successfully returns a list of users' do
        get '/api/users',
            headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        expect(json_body['users'].length).to equal(6)
      end

      it 'returns a list of users without root' do
        get '/api/users',
            headers: root_headers('0').merge(auth_headers(admin))

        expect(response).to have_http_status(:ok)
        expect(json_body.length).to equal(6)
      end

      it 'returns sorted users' do
        get '/api/users',
            headers: auth_headers(admin)

        users = json_body['users']
        (0..users.length - 2).step do |index|
          expect(users[index]['email']).to be <= users[index + 1]['email']
        end
      end

      it 'returns filtered users' do
        get '/api/users?query=aragorn',
            headers: auth_headers(admin)

        users = json_body['users']
        users.each do |user|
          expect(user_contains_string(user, 'aragorn')).to be true
        end
      end
    end

    context 'when public user indexes users' do
      it 'returns 401 forbidden' do
        get '/api/users',
            headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end
    end
  end

  describe 'GET /users/:id' do
    it 'returns 403 unauthorized if user is not authenticated' do
      get "/api/users/#{admin.id}"

      expect(response).to have_http_status(:unauthorized)
      expect(json_body['errors']).to include('token')
    end

    context 'when admin requests user id' do
      it 'returns another admin user' do
        other_admin = create(:user, role: 'admin')
        get "/api/users/#{other_admin.id}",
            headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name', 'last_name', 'email')
      end

      it 'returns the admin user' do
        get "/api/users/#{admin.id}",
            headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name', 'last_name', 'email')
      end

      it 'returns public user' do
        get "/api/users/#{public.id}",
            headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name', 'last_name', 'email')
      end

      it 'returns user serialized by json_api' do
        get "/api/users/#{admin.id}",
            headers: jsonapi_headers.merge(auth_headers(admin))

        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name', 'last_name', 'email')
      end

      it 'returns errors if id does not exist' do
        get '/api/users/1',
            headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
        expect(json_body).to include('errors')
      end
    end

    context 'when public user requests user id' do
      it 'returns their user profile' do
        get "/api/users/#{public.id}",
            headers: auth_headers(public)

        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name', 'last_name', 'email')
      end

      it 'fails to retrieve another user' do
        user = create(:user)
        get "/api/users/#{user.id}",
            headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end

      it 'returns error if id does not exist' do
        get '/api/users/1',
            headers: auth_headers(public)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /users' do
    context 'when params are valid' do
      let(:valid_params) do
        { first_name: 'Aragorn',
          email: 'aragorn.elessar@middle.earth',
          password: 'password' }
      end

      it 'returns status code 201 (created)' do
        post  '/api/users',
              params: { user: valid_params }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:created)
      end

      it 'creates a user' do
        post  '/api/users',
              params: { user: valid_params }.to_json,
              headers: api_headers

        expect(User.all.length).to eq(3)
      end

      it 'assigns correct values to created user' do
        post  '/api/users',
              params: { user: valid_params }.to_json,
              headers: api_headers

        user = User.find_by(first_name: valid_params[:first_name])
        expect(user.email).to eq(valid_params[:email])
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { first_name: '' }
      end

      it 'returns 400 Bad Request' do
        post  '/api/users',
              params: { user: invalid_params }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns errors for all invalid attributes' do
        post  '/api/users',
              params: { user: invalid_params }.to_json,
              headers: api_headers

        expect(json_body['errors']).to include('first_name', 'email')
      end

      it 'does not create user' do
        post  '/api/users',
              params: { user: invalid_params }.to_json,
              headers: api_headers

        expect(User.count).to eq(2)
      end

      it 'does not create user if password is not given' do
        post '/api/users',
             params: { user: { first_name: 'Ime',
                               email: 'ime.prezime@backend.com' } }

        expect(User.count).to eq(2)
        expect(response).to have_http_status(:bad_request)
        expect(json_body).to include('errors')
      end
    end
  end

  describe 'PUT /api/users' do
    let(:update_params) { { first_name: 'Legolas' } }

    context 'when id does not exist' do
      it 'returns errors' do
        put '/api/users/-1',
            params: { user: update_params }.to_json,
            headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
        expect(json_body).to include('errors')
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 unauthorized' do
        put '/api/users/-1',
            params: { user: update_params }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end

    context 'when admin updates user' do
      it 'returns status 200 (ok)' do
        put "/api/users/#{admin.id}",
            params: { user: update_params }.to_json,
            headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
      end

      it 'updates password' do
        put "/api/users/#{admin.id}",
            params: { user: { password: 'password' } }.to_json,
            headers: auth_headers(admin)

        user = User.find_by(email: admin.email).authenticate('password')
        expect(user).not_to eq(nil)
      end

      it 'updates specified values' do
        put "/api/users/#{admin.id}",
            params: { user: update_params }.to_json,
            headers: auth_headers(admin)

        updated_admin = admin.reload
        expect(updated_admin.first_name).to eq(update_params[:first_name])
        expect(updated_admin.email).to eq(admin.email)
      end

      it 'updates user role' do
        put "/api/users/#{public.id}",
            params: { user: { role: 'admin' } }.to_json,
            headers: auth_headers(admin)

        expect(public.reload.admin?).to eq(true)
      end
    end

    context 'when public user updates user' do
      it 'returns status 200 (ok)' do
        put "/api/users/#{public.id}",
            params: { user: update_params }.to_json,
            headers: auth_headers(public)

        expect(response).to have_http_status(:ok)
      end

      it 'updates specified values' do
        put "/api/users/#{public.id}",
            params: { user: update_params }.to_json,
            headers: auth_headers(public)

        updated_public = public.reload
        expect(updated_public.first_name).to eq(update_params[:first_name])
        expect(updated_public.email).to eq(public.email)
      end

      it 'does not update role of user' do
        put "/api/users/#{public.id}",
            params: { user: { role: 'admin' } }.to_json,
            headers: auth_headers(public)

        updated_public = public.reload
        expect(updated_public.admin?).to eq(false)
      end

      it 'returns status 403 forbidden if public user tries to update another user' do
        put "/api/users/#{admin.id}",
            params: { user: update_params }.to_json,
            headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /users/:id' do
    context 'when id does not exist' do
      it 'returns status not found' do
        delete '/api/users/-1',
               headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when admin deletes a user' do
      it 'deletes an admin user' do
        delete "/api/users/#{admin.id}",
               headers: auth_headers(admin)

        expect(response).to have_http_status(:no_content)
        expect(User.all.length).to eq(1)
      end

      it 'deletes a public user' do
        delete "/api/users/#{public.id}",
               headers: auth_headers(admin)

        expect(response).to have_http_status(:no_content)
        expect(User.all.length).to eq(1)
      end
    end

    context 'when public user deletes a user' do
      it 'does not delete an admin' do
        delete "/api/users/#{admin.id}",
               headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
        expect(User.all.length).to eq(2)
      end

      it 'deletes the public user' do
        delete "/api/users/#{public.id}",
               headers: auth_headers(public)

        expect(response).to have_http_status(:no_content)
        expect(User.all.length).to eq(1)
      end
    end
  end

  private

  def user_contains_string(user, str)
    user['first_name'].downcase.include?(str.downcase) ||
      (!user['last_name'].nil? && user['last_name'].downcase.include?(str.downcase)) ||
      user['email'].downcase.include?(str.downcase)
  end
end
