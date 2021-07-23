RSpec.describe 'Flights API', type: :request do
  include TestHelpers::JsonResponse
  let(:company) { create(:company) }

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
    let(:flight) { create(:flight) }

    it 'returns a single flights' do
      get "/api/flights/#{flight.id}"
      json_body = JSON.parse(response.body)

      expect(json_body['flight']).to include('no_of_seats')
    end

    it 'returns a single flight serialized by json_api' do
      get "/api/flights/#{flight.id}",
          headers: jsonapi_headers
      json_body = JSON.parse(response.body)

      expect(json_body['flight']).to include('no_of_seats')
    end
  end

  describe 'POST /flights' do
    let(:company) { create(:company) }

    context 'when params are valid' do
      it 'creates a flight' do
        post  '/api/flights',
              params: { flight: { name: 'Zagreb - Split',
                                  no_of_seats: 10,
                                  base_price: 10,
                                  departs_at: 1.day.after,
                                  arrives_at: 2.days.after,
                                  company_id: company.id } }.to_json,
              headers: api_headers

        expect(json_body['flight']).to include('no_of_seats' => 10)
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/flights',
             params: { flight: { no_of_seats: 0 } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('no_of_seats')
      end
    end
  end

  describe 'PUT /flights/:id' do
    it 'updates a flight' do
      id = post_new_id

      put "/api/flights/#{id}",
          params: { flight: { no_of_seats: 32,
                              base_price: 44 } }.to_json,
          headers: api_headers

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /flight/:id' do
    it 'updates a flight' do
      id = post_new_id

      patch "/api/flights/#{id}",
            params: { flight: { no_of_seats: 10,
                                base_price: 10 } }.to_json,
            headers: api_headers

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE /flights/:id' do
    it 'delete a flight' do
      id = post_new_id

      delete "/api/flights/#{id}"

      expect(response).to have_http_status(:no_content)
    end
  end

  def post_new_id
    post  '/api/flights',
          params: { flight: { name: 'Zagreb - Split',
                              no_of_seats: 10,
                              base_price: 10,
                              departs_at: 1.day.after,
                              arrives_at: 2.days.after,
                              company_id: company.id } }.to_json,
          headers: api_headers

    json_body['flight']['id']
  end
end
