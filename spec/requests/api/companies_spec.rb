RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse
  let!(:admin) { create(:user, token: 'admin-token', role: 'admin') }
  let!(:public) { create(:user, token: 'public-token') }

  describe 'GET /companies' do
    before do
      company1 = create(:company)
      company2 = create(:company)
      company3 = create(:company)
      inactive_flight1 = create(:flight, departs_at: 1.day.before, company: company1)
      inactive_flight2 = create(:flight, departs_at: 1.day.before, arrives_at: Time.zone.now,
                                         company: company3)
      active_flight1 = create(:flight, departs_at: 1.day.after, company: company2)
      active_flight2 = create(:flight, departs_at: 1.day.after, arrives_at: 2.days.after,
                                       company: company3)
      active_flight3 = create(:flight, departs_at: 3.days.after, arrives_at: 4.days.after,
                                       company: company3)

      company1.flights = [inactive_flight1]
      company2.flights = [active_flight1]
      company3.flights = [inactive_flight2, active_flight2, active_flight3]
    end

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

    it 'returns sorted companies' do
      get '/api/companies'

      company_names = json_body['companies'].map { |company| company['name'] }
      expect(company_names[0]).to be <= company_names[1]
      expect(company_names[1]).to be <= company_names[2]
    end

    it 'returns companies with active flights' do
      get '/api/companies?filter=active'

      companies = json_body['companies']
      expect(response).to have_http_status(:ok)
      expect(companies.length).to equal(2)
      companies.each do |company|
        expect(company['flights'].any? do |flight|
                 Time.zone.parse(flight['departs_at']) > Time.zone.now
               end).to be true
      end
    end

    it 'returns number of active flights' do
      get '/api/companies'

      companies = json_body['companies']
      active_flights = companies.map do |company|
        company['flights'].select do |flight|
          Time.zone.parse(flight['departs_at']) > Time.zone.now
        end.size
      end

      (0..companies.length - 1).step do |index|
        expect(companies[index]['no_of_active_flights'].to_i).to eq(active_flights[index])
      end
    end
  end

  describe 'GET /companies/:id' do
    context 'when company id exists' do
      let!(:company) { create(:company) }

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

      it 'returns status code 201 (created) if admin sends POST request' do
        post  '/api/companies',
              params: { company: valid_params }.to_json,
              headers: auth_headers(admin)

        expect(response).to have_http_status(:created)
      end

      it 'creates a company if admin sends POST request' do
        post  '/api/companies',
              params: { company: valid_params }.to_json,
              headers: auth_headers(admin)

        expect(Company.count).to eq(1)
      end

      it 'assigns correct values to created company if admin sends POST request' do
        post  '/api/companies',
              params: { company: valid_params }.to_json,
              headers: auth_headers(admin)

        expect(Company.first.name).to eq(valid_params[:name])
      end

      it 'returns status code 403 forbidden if public user sends POST request' do
        post  '/api/companies',
              params: { company: valid_params }.to_json,
              headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end

      it 'does not create a company if public user sends POST request' do
        post  '/api/companies',
              params: { company: valid_params }.to_json,
              headers: auth_headers(public)

        expect(Company.count).to eq(0)
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { name: '' }
      end

      it 'returns 400 Bad Request' do
        post  '/api/companies',
              params: { company: invalid_params }.to_json,
              headers: auth_headers(admin)

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns errors for all invalid attributes' do
        post  '/api/companies',
              params: { company: invalid_params }.to_json,
              headers: auth_headers(admin)

        expect(json_body['errors']).to include('name')
      end

      it 'does not create company' do
        post  '/api/companies',
              params: { company: invalid_params }.to_json,
              headers: auth_headers(admin)

        expect(Company.count).to eq(0)
      end
    end
  end

  describe 'PUT /companies' do
    let(:update_params) { { name: 'Elves' } }

    context 'when id does not exist' do
      it 'returns errors' do
        put '/api/companies/1',
            params: { company: update_params }.to_json,
            headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
        expect(json_body).to include('errors')
      end
    end

    context 'when id exists' do
      let!(:company) { create(:company, name: 'Dunedain') }

      it 'returns status code 200 ok if admin sends PUT request' do
        put "/api/companies/#{company.id}",
            params: { company: update_params }.to_json,
            headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
      end

      it 'updates specified values if admin sends PUT request' do
        put "/api/companies/#{company.id}",
            params: { company: update_params }.to_json,
            headers: auth_headers(admin)

        expect(company.reload.name).to eq('Elves')
      end

      it 'returns status code 403 forbidden if public user sends PUT request' do
        put "/api/companies/#{company.id}",
            params: { company: update_params }.to_json,
            headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end

      it 'does not update the company if public user sends PUT request' do
        put "/api/companies/#{company.id}",
            params: { company: update_params }.to_json,
            headers: auth_headers(public)

        expect(company.reload.name).to eq(company.name)
      end
    end
  end

  describe 'DELETE /companies/:id' do
    context 'when id does not exist' do
      it 'returns status not found' do
        delete '/api/companies/1',
               headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when admin deletes a company' do
      let!(:company) { create(:company) }

      it 'deletes a company' do
        delete "/api/companies/#{company.id}",
               headers: auth_headers(admin)

        expect(response).to have_http_status(:no_content)
        expect(Company.all.length).to eq(0)
      end
    end

    context 'when public user deletes a company' do
      let!(:company) { create(:company) }

      it 'returns 403 forbidden' do
        delete "/api/companies/#{company.id}",
               headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end

      it 'does not delete the company' do
        delete "/api/companies/#{company.id}",
               headers: auth_headers(public)

        expect(Company.all.length).to eq(1)
      end
    end
  end
end
