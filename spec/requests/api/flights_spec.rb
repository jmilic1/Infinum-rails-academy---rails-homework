RSpec.describe 'Flights API', type: :request do
  include TestHelpers::JsonResponse
  let!(:admin) { create(:user, token: 'admin-token', role: 'admin') }
  let!(:public) { create(:user, token: 'public-token') }

  describe 'GET /flights' do
    before { create_list(:flight, 3) }

    it 'successfully returns a list of flights' do
      get '/api/flights'

      expect(response).to have_http_status(:ok)
      expect(json_body['flights'].length).to equal(3)
    end

    it 'returns a list of flights without root' do
      get '/api/flights',
          headers: root_headers('0')

      expect(response).to have_http_status(:ok)
      expect(json_body.length).to equal(3)
    end
  end

  describe 'GET /flights/:id' do
    let!(:flight) { create(:flight) }

    context 'when flight id exists' do
      it 'returns a single flight' do
        get "/api/flights/#{flight.id}"

        expect(response).to have_http_status(:ok)
        expect(json_body['flight']).to include('name',
                                               'no_of_seats',
                                               'base_price',
                                               'departs_at',
                                               'arrives_at')
      end

      it 'returns a single flight serialized by json_api' do
        get "/api/flights/#{flight.id}",
            headers: jsonapi_headers

        expect(response).to have_http_status(:ok)
        expect(json_body['flight']).to include('name',
                                               'no_of_seats',
                                               'base_price',
                                               'departs_at',
                                               'arrives_at')
      end
    end

    context 'when flight id does not exist' do
      it 'returns errors' do
        get '/api/flights/1'

        expect(response).to have_http_status(:not_found)
        expect(json_body).to include('errors')
      end
    end
  end

  describe 'POST /flights' do
    context 'when params are valid' do
      let(:valid_params) do
        { name: 'Minas Tirith - Minas Morgul',
          no_of_seats: 20,
          base_price: 30,
          departs_at: 10.days.after,
          arrives_at: 11.days.after,
          company_id: create(:company).id }
      end

      it 'returns status code 201 (created) if admin sends POST request' do
        post  '/api/flights',
              params: { flight: valid_params }.to_json,
              headers: auth_headers(admin)

        expect(response).to have_http_status(:created)
      end

      it 'creates a flight if admin sends POST request' do
        post  '/api/flights',
              params: { flight: valid_params }.to_json,
              headers: auth_headers(admin)

        expect(Flight.count).to eq(1)
      end

      it 'assigns correct values to created flight if admin sends POST request' do
        post  '/api/flights',
              params: { flight: valid_params }.to_json,
              headers: auth_headers(admin)

        flight = Flight.first
        expect(flight.name).to eq(valid_params[:name])
        expect(flight.no_of_seats).to eq(valid_params[:no_of_seats])
        expect(flight.base_price).to eq(valid_params[:base_price])
      end

      it 'returns status code 403 forbidden if public user sends POST request' do
        post  '/api/flights',
              params: { flight: valid_params }.to_json,
              headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end

      it 'does not create a flight if public user sends POST request' do
        post  '/api/flights',
              params: { flight: valid_params }.to_json,
              headers: auth_headers(public)

        expect(Flight.count).to eq(0)
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { no_of_seats: 0 }
      end

      it 'returns 400 Bad Request' do
        post  '/api/flights',
              params: { flight: invalid_params }.to_json,
              headers: auth_headers(admin)

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns errors for all invalid attributes' do
        post  '/api/flights',
              params: { flight: invalid_params }.to_json,
              headers: auth_headers(admin)

        expect(json_body['errors']).to include('name',
                                               'no_of_seats',
                                               'base_price',
                                               'departs_at',
                                               'arrives_at',
                                               'company')
      end

      it 'does not create flight' do
        post  '/api/flights',
              params: { flight: invalid_params }.to_json,
              headers: auth_headers(admin)

        expect(Flight.count).to eq(0)
      end
    end
  end

  describe 'PUT /flights' do
    let(:update_params) { { no_of_seats: 32 } }

    context 'when id does not exist' do
      it 'returns errors' do
        put '/api/flights/1',
            params: { flight: update_params }.to_json,
            headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
        expect(json_body).to include('errors')
      end
    end

    context 'when id exists' do
      let!(:flight) { create(:flight, name: 'Zagreb - Split', no_of_seats: 10) }

      it 'returns status code 200 ok if admin sends PUT request' do
        put "/api/flights/#{flight.id}",
            params: { flight: update_params }.to_json,
            headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
      end

      it 'updates specified values if admin sends PUT request' do
        put "/api/flights/#{flight.id}",
            params: { flight: update_params }.to_json,
            headers: auth_headers(admin)

        updated_flight = flight.reload
        expect(updated_flight.name).to eq('Zagreb - Split')
        expect(updated_flight.no_of_seats).to eq(32)
      end

      it 'returns status code 403 forbidden if public user sends PUT request' do
        put "/api/flights/#{flight.id}",
            params: { flight: update_params }.to_json,
            headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end

      it 'does not update the flight if public user sends PUT request' do
        put "/api/flights/#{flight.id}",
            params: { flight: update_params }.to_json,
            headers: auth_headers(public)

        expect(flight.reload.no_of_seats).to eq(flight.no_of_seats)
      end
    end
  end

  describe 'DELETE /flights/:id' do
    context 'when id does not exist' do
      it 'returns status not found' do
        delete '/api/flights/1',
               headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when admin deletes a flight' do
      let!(:flight) { create(:flight) }

      it 'deletes a flight' do
        delete "/api/flights/#{flight.id}",
               headers: auth_headers(admin)

        expect(response).to have_http_status(:no_content)
        expect(Flight.all.length).to eq(0)
      end
    end

    context 'when public user deletes a flight' do
      let!(:flight) { create(:flight) }

      it 'returns 403 forbidden' do
        delete "/api/flights/#{flight.id}",
               headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end

      it 'does not delete the flight' do
        delete "/api/flights/#{flight.id}",
               headers: auth_headers(public)

        expect(Flight.all.length).to eq(1)
      end
    end
  end
end
