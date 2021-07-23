RSpec.describe 'Bookings API', type: :request do
  include TestHelpers::JsonResponse
  let(:flight) { create(:flight) }
  let(:user) { create(:user) }

  describe 'GET /bookings' do
    before { create_list(:booking, 3) }

    it 'successfully returns a list of bookings' do
      get '/api/bookings'

      expect(response).to have_http_status(:ok)
      expect(json_body['bookings'].length).to equal(3)
    end

    it 'returns a list of bookings without root' do
      get '/api/bookings',
          headers: root_headers('0')

      expect(response).to have_http_status(:ok)
      expect(json_body.length).to equal(3)
    end
  end

  describe 'GET /bookings/:id' do
    let(:booking) { create(:booking) }

    it 'returns a single booking' do
      get "/api/bookings/#{booking.id}"
      json_body = JSON.parse(response.body)

      expect(json_body['booking']).to include('no_of_seats')
    end

    it 'returns a single booking serialized by json_api' do
      get "/api/bookings/#{booking.id}",
          headers: jsonapi_headers
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

        puts json_body
        expect(json_body['booking']).to include('no_of_seats' => 10)
      end

      # rubocop:disable RSpec/ExampleLength
      it 'checks a booking was created' do
        no_of_seats = 25
        seat_price = 29
        post  '/api/bookings',
              params: { booking: { no_of_seats: no_of_seats,
                                   seat_price: seat_price,
                                   flight_id: flight.id,
                                   user_id: user.id } }.to_json,
              headers: api_headers

        id = json_body['booking']['id']

        get "/api/bookings/#{id}"

        expect(json_body['booking']).to include('id' => id,
                                                'no_of_seats' => no_of_seats,
                                                'seat_price' => seat_price)
      end
    end
    # rubocop:enable RSpec/ExampleLength

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

  describe 'PUT /bookings/:id' do
    it 'updates a booking' do
      id = post_new_id

      put "/api/bookings/#{id}",
          params: { booking: { no_of_seats: 32,
                               seat_price: 44 } }.to_json,
          headers: api_headers

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /bookings/:id' do
    it 'updates a booking' do
      id = post_new_id

      patch "/api/bookings/#{id}",
            params: { booking: { no_of_seats: 10,
                                 seat_price: 10 } }.to_json,
            headers: api_headers

      expect(response).to have_http_status(:ok)
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
