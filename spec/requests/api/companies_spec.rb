RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse

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
    let!(:company) { create(:company) }

    context 'when company id exists' do
      it 'returns a single company' do
        get "/api/companies/#{company.id}"

        expect(response).to have_http_status(:ok)
        expect(json_body['company']).to include('name')
      end

      it 'returns a single company serialized by json_api' do
        get "/api/companies/#{company.id}",
            headers: jsonapi_headers

        expect(response).to have_http_status(:ok)
        expect(json_body['company']).to include('name')
      end
    end

    context 'when company id does not exist' do
      it 'returns errors' do
        get '/api/companies/1'

        expect(response).to have_http_status(:not_found)
        expect(json_body).to include('errors')
      end
    end
  end

  describe 'POST /companies' do
    context 'when params are valid' do
      let(:valid_params) do
        { name: 'Eagle Express' }
      end

      it 'returns status code 201 (created)' do
        post  '/api/companies',
              params: { company: valid_params }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:created)
      end

      it 'creates a company' do
        post  '/api/companies',
              params: { company: valid_params }.to_json,
              headers: api_headers

        expect(Company.count).to eq(1)
      end

      it 'assigns correct values to created company' do
        post  '/api/companies',
              params: { company: valid_params }.to_json,
              headers: api_headers

        expect(Company.first.name).to eq(valid_params[:name])
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { name: '' }
      end

      it 'returns 400 Bad Request' do
        post  '/api/companies',
              params: { company: invalid_params }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns errors for all invalid attributes' do
        post  '/api/companies',
              params: { company: invalid_params }.to_json,
              headers: api_headers

        expect(json_body['errors']).to include('name')
      end

      it 'does not create company' do
        post  '/api/companies',
              params: { company: invalid_params }.to_json,
              headers: api_headers

        expect(Company.count).to eq(0)
      end
    end
  end

  describe 'updating companies' do
    let(:update_params) { { name: 'Elves' } }

    context 'when id does not exist' do
      it 'returns errors' do
        put '/api/companies/1',
            params: { company: update_params }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:not_found)
        expect(json_body).to include('errors')
      end
    end

    context 'when id exists' do
      let!(:company) { create(:company, name: 'Dunedain') }

      it 'updates specified values' do
        put "/api/companies/#{company.id}",
            params: { company: update_params }.to_json,
            headers: api_headers

        expect(company.reload.name).to eq('Elves')
      end

      it 'returns status 200 (ok)' do
        put "/api/companies/#{company.id}",
            params: { company: update_params }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'DELETE /companies/:id' do
    it 'deletes a company' do
      company = create(:company)

      delete "/api/companies/#{company.id}"

      expect(response).to have_http_status(:no_content)
      expect(Company.all.length).to eq(0)
    end
  end
end
