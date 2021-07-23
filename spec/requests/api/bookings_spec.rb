RSpec.describe 'Bookings API', type: :request do
  include TestHelpers::JsonResponse
  let(:flight) { create(:flight) }
  let(:admin_token) { 'admin-token' }
  let(:public_token) { 'public-token' }

  before do
    create(:user, token: admin_token, role: 'admin')
    create(:user, token: public_token, role: 'public')
  end

  describe 'GET /bookings' do
    before do
      post  '/api/bookings',
            params: { booking: { no_of_seats: 10,
                                 seat_price: 10,
                                 flight_id: flight.id } }.to_json,
            headers: auth_headers(admin_token)

      post  '/api/bookings',
            params: { booking: { no_of_seats: 20,
                                 seat_price: 20,
                                 flight_id: flight.id } }.to_json,
            headers: auth_headers(admin_token)
    end

    it 'successfully returns a list of bookings' do
      get '/api/bookings',
          headers: auth_headers(admin_token)

      expect(response).to have_http_status(:ok)
      expect(json_body['bookings'].length).to equal(2)
    end

    it 'returns a list of bookings without root' do
      get '/api/bookings',
          headers: auth_headers(admin_token).merge(root_headers('0'))

      expect(response).to have_http_status(:ok)
      expect(json_body.length).to equal(2)
    end
  end

  describe 'GET /bookings/:id' do
    let(:booking) do
      post '/api/bookings',
           params: { booking: { no_of_seats: 20,
                                seat_price: 20,
                                flight_id: flight.id } }.to_json,
           headers: auth_headers(admin_token)
      json_body['booking']
    end

    it 'returns a single booking' do
      get "/api/bookings/#{booking['id']}",
          headers: auth_headers(admin_token)

      expect(json_body['booking']).to include('no_of_seats' => 20)
    end

    it 'returns a single booking serialized by json_api' do
      get "/api/bookings/#{booking['id']}",
          headers: jsonapi_headers.merge(auth_headers(admin_token))

      expect(json_body['booking']).to include('no_of_seats')
    end
  end

  describe 'POST /bookings' do
    context 'when params are valid' do
      it 'creates a booking' do
        no_of_seats = 25
        seat_price = 30
        id = post_new_id(no_of_seats, seat_price)

        get "/api/bookings/#{id}",
            headers: auth_headers(admin_token)

        expect(json_body['booking']).to include('id' => id,
                                                'no_of_seats' => no_of_seats,
                                                'seat_price' => seat_price)
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/bookings',
             params: { booking: { no_of_seats: 0 } }.to_json,
             headers: auth_headers(admin_token)

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('no_of_seats')
      end
    end
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe 'updating bookings' do
    let(:no_of_seats) { 25 }
    let(:old_seat_price) { 30 }
    let(:new_seat_price) { 65 }

    it 'sends PUT /bookings/:id request' do
      id = post_new_id(no_of_seats, old_seat_price)

      put "/api/bookings/#{id}",
          params: { booking: { seat_price: new_seat_price } }.to_json,
          headers: auth_headers(admin_token)

      expect(response).to have_http_status(:ok)
      expect(json_body['booking']).to include('id' => id,
                                              'no_of_seats' => no_of_seats,
                                              'seat_price' => new_seat_price)
    end

    it 'sends PATCH /bookings/:id request' do
      id = post_new_id(no_of_seats, old_seat_price)

      patch "/api/bookings/#{id}",
            params: { booking: { seat_price: new_seat_price } }.to_json,
            headers: auth_headers(admin_token)

      expect(response).to have_http_status(:ok)
      expect(json_body['booking']).to include('id' => id,
                                              'no_of_seats' => no_of_seats,
                                              'seat_price' => new_seat_price)
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers

    it 'does not update user id of bookings' do
      booking = post_new(10, 20)
      id = booking['id']
      user_id = booking['user']['id']

      put "/api/bookings/#{id}",
          params: { booking: { user_id: user_id + 1 } }.to_json,
          headers: auth_headers(admin_token)

      expect(response).to have_http_status(:ok)
      expect(json_body['booking']).to include('id' => id)
      expect(json_body['booking']['user']).to include('id' => user_id)
    end
  end

  describe 'DELETE /bookings/:id' do
    it 'deletes a booking' do
      id = post_new_id(10, 20)

      delete "/api/bookings/#{id}",
             headers: auth_headers(admin_token)

      expect(response).to have_http_status(:no_content)

      get "/api/bookings/#{id}", headers: auth_headers(admin_token)

      expect(response).to have_http_status(:not_found)
    end
  end

  def post_new_id(no_of_seats, seat_price)
    post  '/api/bookings',
          params: { booking: { no_of_seats: no_of_seats,
                               seat_price: seat_price,
                               flight_id: flight.id } }.to_json,
          headers: auth_headers(admin_token)

    json_body['booking']['id']
  end

  def post_new(no_of_seats, seat_price)
    post  '/api/bookings',
          params: { booking: { no_of_seats: no_of_seats,
                               seat_price: seat_price,
                               flight_id: flight.id } }.to_json,
          headers: auth_headers(admin_token)

    json_body['booking']
  end
end
