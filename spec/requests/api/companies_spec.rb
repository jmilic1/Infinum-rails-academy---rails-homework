RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse
  let!(:admin) { create(:user, token: 'admin-token', role: 'admin') }
  let!(:public) { create(:user, token: 'public-token') }

  # rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/ExampleLength
  describe 'GET /companies' do
    context 'when executing a basic index' do
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

      it 'returns sorted companies' do
        get '/api/companies'

        company_names = json_body['companies'].map { |company| company['name'] }
        (0..company_names.length - 2).step do |index|
          expect(company_names[index]).to be <= company_names[index + 1]
        end
      end
    end

    context 'when checking fields' do
      let(:expected_no_of_active_flights) { [0, 1, 2] }
      let(:names) { ['first company name', 'second company name', 'third company name'] }
      let!(:first_company) { create(:company, name: names[0]) }
      let!(:second_company) { create(:company, name: names[1]) }
      let!(:third_company) { create(:company, name: names[2]) }

      before do
        inactive_flight1 = create(:flight, departs_at: 1.day.before, company: first_company)
        inactive_flight2 = create(:flight, departs_at: 1.day.before, arrives_at: Time.zone.now,
                                           company: third_company)
        active_flight1 = create(:flight, departs_at: 1.day.after, company: second_company)
        active_flight2 = create(:flight, departs_at: 1.day.after, arrives_at: 2.days.after,
                                         company: third_company)
        active_flight3 = create(:flight, departs_at: 3.days.after, arrives_at: 4.days.after,
                                         company: third_company)

        first_company.flights = [inactive_flight1]
        second_company.flights = [active_flight1]
        third_company.flights = [inactive_flight2, active_flight2, active_flight3]
      end

      it 'returns companies with active flights' do
        get '/api/companies?filter=active'

        expect(response).to have_http_status(:ok)

        expect(json_body['companies'].map do |company|
          company['id']
        end).to include(second_company.id, third_company.id)
      end

      it 'returns number of active flights' do
        get '/api/companies'

        json_body['companies'].each do |company|
          case company['id']
          when first_company.id
            expect(company['no_of_active_flights'].to_i).to eq(expected_no_of_active_flights[0])
          when second_company.id
            expect(company['no_of_active_flights'].to_i).to eq(expected_no_of_active_flights[1])
          else
            expect(company['no_of_active_flights'].to_i).to eq(expected_no_of_active_flights[2])
          end
        end
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/ExampleLength

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
        post '/api/companies',
             params: { company: valid_params }.to_json,
             headers: auth_headers(admin)

        expect(response).to have_http_status(:created)
      end

      it 'creates a company if admin sends POST request' do
        post '/api/companies',
             params: { company: valid_params }.to_json,
             headers: auth_headers(admin)

        expect(Company.count).to eq(1)
      end

      it 'assigns correct values to created company if admin sends POST request' do
        post '/api/companies',
             params: { company: valid_params }.to_json,
             headers: auth_headers(admin)

        expect(Company.first.name).to eq(valid_params[:name])
      end

      it 'returns status code 403 forbidden if public user sends POST request' do
        post '/api/companies',
             params: { company: valid_params }.to_json,
             headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end

      it 'does not create a company if public user sends POST request' do
        post '/api/companies',
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
        post '/api/companies',
             params: { company: invalid_params }.to_json,
             headers: auth_headers(admin)

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns errors for all invalid attributes' do
        post '/api/companies',
             params: { company: invalid_params }.to_json,
             headers: auth_headers(admin)

        expect(json_body['errors']).to include('name')
      end

      it 'does not create company' do
        post '/api/companies',
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
