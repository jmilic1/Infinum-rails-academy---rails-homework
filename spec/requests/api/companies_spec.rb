RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse

  let!(:companies) { FactoryBot.create_list(:company, 3) }

  describe 'GET /companies' do
    it 'successfully returns a list of companies' do
      get '/api/companies'

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /companies/:id' do
    it 'returns a single company' do
      get "/api/companies/#{companies.first.id}"
      json_body = JSON.parse(response.body)

      expect(json_body['company']).to include('name')
    end

    it 'returns a single company serialized by json_api' do
      get "/api/companies/#{companies.first.id}",
          headers: jsonapi_headers
      json_body = JSON.parse(response.body)

      expect(json_body['company']).to include('name')
    end
  end

  describe 'POST /companies' do
    context 'when params are valid' do
      it 'creates a company' do
        post  '/api/companies',
              params: { company: { name: 'Croatia Airlines' } }.to_json,
              headers: api_headers

        expect(json_body['company']).to include('"name":"Croatia Airlines"')
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/companies',
             params: { company: { name: '' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end
    end
  end

  describe 'PUT /companies/:id' do
    it 'updates a company' do
      id = post_new_id

      put "/api/companies/#{id}",
          params: { company: { name: 'Eagle Airways' } }.to_json,
          headers: api_headers

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'PATCH /companies/:id' do
    it 'updates a company' do
      id = post_new_id

      patch "/api/companies/#{id}",
            params: { company: { name: 'Eagle Airways' } }.to_json,
            headers: api_headers

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'DELETE /companies/:id' do
    it 'delete a company' do
      id = post_new_id

      delete "/api/companies/#{id}"

      expect(response).to have_http_status(:no_content)
    end
  end

  def post_new_id
    post  '/api/companies',
          params: { company: { name: 'Croatia Airlines' } }.to_json,
          headers: api_headers

    JSON.parse(json_body['company'])['id']
  end
end
