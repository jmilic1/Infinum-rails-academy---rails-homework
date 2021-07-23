RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse
  let(:admin_token) { 'admin-token' }
  let(:public_token) { 'public-token' }

  before do
    create(:user, token: admin_token, role: 'admin')
    create(:user, token: public_token, role: 'public')
  end

  describe 'GET /companies' do
    before { create_list(:company, 3) }

    it 'successfully returns a list of companies' do
      get '/api/companies'

      expect(response).to have_http_status(:ok)
      expect(json_body['companies'].length).to equal(3)
    end

    it 'returns a list of companies without root' do
      get '/api/companies',
          headers: root_headers('0')

      expect(response).to have_http_status(:ok)
      expect(json_body.length).to equal(3)
    end
  end

  describe 'GET /companies/:id' do
    let(:company) { create(:company) }

    it 'returns a single company' do
      get "/api/companies/#{company.id}"

      expect(json_body['company']).to include('name')
    end

    it 'returns a single company serialized by json_api' do
      get "/api/companies/#{company.id}",
          headers: jsonapi_headers

      expect(json_body['company']).to include('name')
    end
  end

  describe 'POST /companies' do
    context 'when params are valid' do
      it 'creates a company' do
        name = 'Eagle Express'
        id = post_new_id(name)

        get "/api/companies/#{id}"

        expect(json_body['company']).to include('id' => id, 'name' => name)
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/companies',
             params: { company: { name: '' } }.to_json,
             headers: auth_headers(admin_token)

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end
    end
  end

  describe 'updating companies' do
    let(:old_name) { 'Dunedain' }
    let(:new_name) { 'Elves' }

    it 'sends PUT /companies/:id request' do
      id = post_new_id(old_name)

      put "/api/companies/#{id}",
          params: { company: { name: new_name } }.to_json,
          headers: auth_headers(admin_token)

      expect(response).to have_http_status(:ok)
      expect(json_body['company']).to include('id' => id, 'name' => new_name)
    end

    it 'sends PATCH /companies/:id request' do
      id = post_new_id(old_name)

      patch "/api/companies/#{id}",
            params: { company: { name: new_name } }.to_json,
            headers: auth_headers(admin_token)

      expect(response).to have_http_status(:ok)
      expect(json_body['company']).to include('id' => id, 'name' => new_name)
    end
  end

  describe 'DELETE /companies/:id' do
    it 'deletes a company' do
      id = post_new_id('Dunedain')

      delete "/api/companies/#{id}",
             headers: auth_headers(admin_token)

      expect(response).to have_http_status(:no_content)

      get "/api/companies/#{id}"

      expect(response).to have_http_status(:not_found)
    end
  end

  def post_new_id(name)
    post  '/api/companies',
          params: { company: { name: name } }.to_json,
          headers: auth_headers(admin_token)

    json_body['company']['id']
  end
end
