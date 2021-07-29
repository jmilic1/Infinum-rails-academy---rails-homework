RSpec.describe 'Session API', type: :request do
  include TestHelpers::JsonResponse
  let(:password) { 'password-numero' }
  let(:admin_token) { 'admin-token' }
  let(:public_token) { 'public-token' }
  let(:email) { 'myEmail.backend@backend.com' }

  before do
    create(:user, email: email, password: password, token: admin_token, role: 'admin')
  end

  describe 'POST /session' do
    context 'when params are valid' do
      it 'creates a session' do
        post  '/api/session',
              params: { session: { email: email,
                                   password: password } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:created)
        json = json_body
        expect(json['session']).to include('user')
        expect(json['session']).to include('token')
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request if no email is given' do
        post  '/api/session',
              params: { session: { password: password } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        json = json_body
        expect(json['errors']).to include('credentials')
      end

      it 'returns 400 Bad Request if wrong email is given' do
        post  '/api/session',
              params: { session: { email: 'wrong.email@bad.com',
                                   password: password } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('credentials')
      end

      it 'returns 400 Bad Request if wrong password is given' do
        post  '/api/session',
              params: { session: { email: email,
                                   password: 'wrong password whoops' } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('credentials')
      end

      it 'returns 400 Bad Request if no password is given' do
        post  '/api/session',
              params: { session: { email: email } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('credentials')
      end

      it 'returns 400 Bad Request if blank password is given' do
        post  '/api/session',
              params: { session: { email: email,
                                   password: '' } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('credentials')
      end
    end
  end

  describe 'DELETE /session' do
    context 'when token exists' do
      let!(:user) { create(:user, token: 'atoken') }

      it 'successfully logs out current user' do
        delete '/api/session',
               headers: auth_headers(user)

        expect(response).to have_http_status(:no_content)

        old_token = user.token
        new_token = user.reload.token
        expect(old_token).to_not eq(new_token)
      end
    end

    context 'when token does not exist' do
      let!(:user) { User.new(token: 'bad token') }

      it 'successfully logs out current' do
        delete '/api/session',
               headers: auth_headers(user)

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token')
      end
    end
  end
end
