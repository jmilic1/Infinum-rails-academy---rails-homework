RSpec.describe 'Session API', type: :request do
  include TestHelpers::JsonResponse
  let(:password) { 'password-numero' }
  let(:admin_token) { 'admin-token' }
  let(:public_token) { 'public-token' }
  let(:email) { 'myEmail.backend@backend.com' }

  before do
    create(:user, email: email, password: password, token: admin_token, role: 'admin')
  end

  describe 'POST /sessions' do
    context 'when params are valid' do
      it 'creates a session' do
        post  '/api/sessions',
              params: { session: { email: email,
                                   password: password } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:ok)
        json = json_body
        expect(json['session']).to include('user')
        expect(json['session']).to include('token')
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request if no email is given' do
        post  '/api/sessions',
              params: { session: { password: password } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        json = json_body
        expect(json['errors']).to include('credentials')
      end

      it 'returns 400 Bad Request if wrong email is given' do
        post  '/api/sessions',
              params: { session: { email: 'wrong.email@bad.com',
                                   password: password } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('credentials')
      end

      it 'returns 400 Bad Request if wrong password is given' do
        post  '/api/sessions',
              params: { session: { email: email,
                                   password: 'wrong password whoops' } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('credentials')
      end

      it 'returns 400 Bad Request if no password is given' do
        post  '/api/sessions',
              params: { session: { email: email } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('credentials')
      end

      it 'returns 400 Bad Request if blank password is given' do
        post  '/api/sessions',
              params: { session: { email: email,
                                   password: '' } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('credentials')
      end
    end
  end

  describe 'DELETE /sessions' do
    it 'successfully logs out current user' do
      token = post_new_session
      delete '/api/sessions',
             headers: auth_headers(token)

      expect(response).to have_http_status(:no_content)

      get '/api/bookings',
          headers: auth_headers(token)

      expect(response).to have_http_status(:unauthorized)
      expect(json_body['errors']).to include('token')
    end
  end

  def post_new_session
    post  '/api/sessions',
          params: { session: { email: email,
                               password: password } }.to_json,
          headers: api_headers
    json_body['session']['token']
  end

  def post_new_user
    post  '/api/users',
          params: { user: { first_name: 'Ime',
                            email: 'ime.prezime@backend.com',
                            password: password } }.to_json,
          headers: api_headers

    json_body['user']
  end
end
