RSpec.describe 'Bookings API', type: :request do
  include TestHelpers::JsonResponse

  let(:flight) do
    FactoryBot.create(:flight)
  end

  let(:user) do
    FactoryBot.create(:user)
  end

  let!(:bookings) { FactoryBot.create_list(:booking, 3) }

  describe 'GET /bookings' do
    it 'successfully returns a list of bookings' do
      get '/api/bookings'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /bookings/:id' do
    it 'returns a single booking' do
      get "/api/bookings/#{bookings.first.id}"
      json_body = JSON.parse(response.body)
      expect(json_body['booking']).to include('no_of_seats')
    end
  end

  describe 'GET /bookings/:id/edit' do
    it 'returns a single booking' do
      get "/api/bookings/#{bookings.first.id}/edit"
      json_body = JSON.parse(response.body)
      expect(json_body['booking']).to include('no_of_seats')
    end
  end

  describe 'POST /bookings' do
    context 'when params are valid' do
      it 'creates a booking' do
        post  '/api/bookings',
              params: { booking: { no_of_seats: 10,
                                   seat_price: 10,
                                   flight_id: flight.id,
                                   user_id: user.id } }.to_json,
              headers: api_headers

        expect(json_body['booking']).to include('no_of_seats' => 10)
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/bookings',
             params: { booking: { no_of_seats: 0 } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('no_of_seats')
      end
    end
  end

  describe 'GET /bookings/new' do
    it 'returns an empty booking that does not exist in database' do
      get '/api/bookings/new'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT /bookings/:id' do
    it 'updates a booking' do
      id = post_new_id

      put "/api/bookings/#{id}",
          params: { booking: { no_of_seats: 32,
                               seat_price: 44 } }.to_json,
          headers: api_headers

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'PATCH /bookings/:id' do
    it 'updates a booking' do
      id = post_new_id

      patch "/api/bookings/#{id}",
            params: { booking: { no_of_seats: 10,
                                 seat_price: 10 } }.to_json,
            headers: api_headers

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'DELETE /bookings/:id' do
    it 'delete a booking' do
      id = post_new_id

      delete "/api/bookings/#{id}"

      expect(response).to have_http_status(:no_content)
    end
  end

  def post_new_id
    post  '/api/bookings',
          params: { booking: { no_of_seats: 10,
                               seat_price: 10,
                               flight_id: flight.id,
                               user_id: user.id } }.to_json,
          headers: api_headers

    json_body['booking']['id']
  end
end