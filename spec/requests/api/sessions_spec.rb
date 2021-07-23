RSpec.describe 'Session API', type: :request do
  include TestHelpers::JsonResponse
  let(:password) { 'password-numero' }

  describe 'POST /sessions' do
    context 'when params are valid' do
      it 'creates a session' do
        user = post_new_user

        post  '/api/sessions',
              params: { session: { email: user['email'],
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
        post_new_user

        post  '/api/sessions',
              params: { session: { password: password } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        json = json_body
        expect(json['errors']).to include('credentials')
      end

      it 'returns 400 Bad Request if wrong email is given' do
        post_new_user

        post  '/api/sessions',
              params: { session: { email: 'wrong.email@bad.com',
                                   password: password } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('credentials')
      end

      it 'returns 400 Bad Request if wrong password is given' do
        user = post_new_user

        post  '/api/sessions',
              params: { session: { email: user['email'],
                                   password: 'wrong password whoops' } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('credentials')
      end

      it 'returns 400 Bad Request if no password is given' do
        user = post_new_user

        post  '/api/sessions',
              params: { session: { email: user['email'] } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('credentials')
      end

      it 'returns 400 Bad Request if blank password is given' do
        user = post_new_user

        post  '/api/sessions',
              params: { session: { email: user['email'],
                                   password: '' } }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('credentials')
      end
    end
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
