# RSpec.describe 'Users API', type: :request do
#   include TestHelpers::JsonResponse
#
# describe 'GET /users' do
#   before { create_list(:user, 3) }
#
#   it 'successfully returns a list of users' do
#     get '/api/users'
#
#     expect(response).to have_http_status(:unauthorized)
#     expect(json_body['users'].length).to equal(3)
#   end
#
#   it 'returns a list of users without root' do
#     get '/api/users',
#         headers: root_headers('0')
#
#     expect(response).to have_http_status(:unauthorized)
#     expect(json_body.length).to equal(3)
#   end
# end

# describe 'GET /users/:id' do
#   let!(:user) { create(:user) }
#
#   context 'when user id exists' do
#     it 'returns a single user' do
#       get "/api/users/#{user.id}"
#
#       expect(response).to have_http_status(:unauthorized)
#       expect(json_body['user']).to include('first_name', 'last_name', 'email')
#     end
#
#     it 'returns a single user serialized by json_api' do
#       get "/api/users/#{user.id}",
#           headers: jsonapi_headers
#
#       expect(response).to have_http_status(:unauthorized)
#       expect(json_body['user']).to include('first_name', 'last_name', 'email')
#     end
#   end
# end
#
# describe 'POST /users' do
#   context 'when params are valid' do
#     let(:valid_params) do
#       { first_name: 'Aragorn',
#         email: 'aragorn.elessar@middle.earth' }
#     end
#
#     it 'returns status code 201 (created)' do
#       post  '/api/users',
#             params: { user: valid_params }.to_json,
#             headers: api_headers
#
#       expect(response).to have_http_status(:created)
#     end
#
#     it 'creates a user' do
#       post  '/api/users',
#             params: { user: valid_params }.to_json,
#             headers: api_headers
#
#       expect(User.count).to eq(1)
#     end
#
#     it 'assigns correct values to created user' do
#       post  '/api/users',
#             params: { user: valid_params }.to_json,
#             headers: api_headers
#
#       user = User.all.first
#       expect(user.first_name).to eq(valid_params[:first_name])
#       expect(user.last_name).to eq(valid_params[:last_name])
#     end
#   end
#
#   context 'when params are invalid' do
#     let(:invalid_params) do
#       { first_name: '' }
#     end
#
#     it 'returns 400 Bad Request' do
#       post  '/api/users',
#             params: { user: invalid_params }.to_json,
#             headers: api_headers
#
#       expect(response).to have_http_status(:bad_request)
#     end
#
#     it 'returns errors for all invalid attributes' do
#       post  '/api/users',
#             params: { user: invalid_params }.to_json,
#             headers: api_headers
#
#       expect(json_body['errors']).to include('first_name', 'email')
#     end
#
#     it 'does not create user' do
#       post  '/api/users',
#             params: { user: invalid_params }.to_json,
#             headers: api_headers
#
#       expect(User.count).to eq(0)
#     end
#
#     it 'does not create user if password is not given' do
#       post '/api/users',
#            params: { user: { first_name: 'Ime',
#                              email: 'ime.prezime@backend.com' } }
#
#       expect(User.count).to eq(0)
#       expect(response).to have_http_status(:bad_request)
#       expect(json_body).to include('errors')
#     end
#   end
# end
#
# describe 'updating users' do
#   let(:update_params) { { first_name: 'Legolas' } }
#
#   context 'when user is not authenticated' do
#     it 'returns 401 unauthorized' do
#       put '/api/users/1',
#           params: { user: update_params }.to_json,
#           headers: api_headers
#
#       expect(response).to have_http_status(:unauthorized)
#       expect(json_body['errors']).to include('token')
#     end
#   end
#
#   context 'when user is authenticated' do
#     let!(:user) { create(:user, first_name: 'Aragorn', email: 'aragorn.elessar@middle.earth') }
#
#     it 'returns 400 bad request if new password is nil' do
#       put "/api/users/#{user.id}",
#           params: { user: { password: nil } }.to_json,
#           headers: auth_headers(user)
#
#       expect(response).to have_http_status(:bad_request)
#       expect(json_body['errors']).to include('password')
#     end
#
#     it 'returns 400 bad request if new password is blank' do
#       put "/api/users/#{user.id}",
#           params: { user: { password: '' } }.to_json,
#           headers: auth_headers(user)
#
#       expect(response).to have_http_status(:bad_request)
#       expect(json_body['errors']).to include('password')
#     end
#   end
#
#   # OLD
#   context 'when id does not exist' do
#     it 'returns errors' do
#       put '/api/users/1',
#           params: { user: update_params }.to_json,
#           headers: api_headers
#
#       expect(response).to have_http_status(:not_found)
#       expect(json_body).to include('errors')
#     end
#   end
#
#   context 'when id exists' do
#     let!(:user) { create(:user, first_name: 'Aragorn', email: 'aragorn.elessar@middle.earth') }
#
#     it 'updates specified values' do
#       put "/api/users/#{user.id}",
#           params: { user: update_params }.to_json,
#           headers: auth_headers(user)
#
#       user_updated = user.reload
#       expect(user_updated.first_name).to eq('Legolas')
#       expect(user_updated.email).to eq('aragorn.elessar@middle.earth')
#     end
#
#     it 'returns status 200 (ok)' do
#       put "/api/users/#{user.id}",
#           params: { user: update_params }.to_json,
#           headers: api_headers
#
#       expect(response).to have_http_status(:ok)
#     end
#   end
# end
#
# describe 'DELETE /users/:id' do
#   context 'when id does not exist' do
#     it 'returns status not found' do
#       delete '/api/users/1'
#
#       expect(response).to have_http_status(:unauthorized)
#     end
#   end
#
#   context 'when id exists' do
#     it 'deletes a user' do
#       user = create(:user)
#
#       delete "/api/users/#{user.id}"
#
#       expect(response).to have_http_status(:unauthorized)
#       expect(User.all.length).to eq(0)
#     end
#   end
# end
# end
