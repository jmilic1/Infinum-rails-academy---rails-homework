RSpec.describe 'Bookings API', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /bookings' do
    it 'successfully returns a list of bookings' do
      setup_index

      get '/api/bookings'

      expect(response).to have_http_status(:ok)
      expect(json_body['bookings'].length).to equal(3)
    end

    it 'returns a list of bookings without root' do
      setup_index

      get '/api/bookings',
          headers: root_headers('0')

      expect(response).to have_http_status(:ok)
      expect(json_body.length).to equal(3)
    end
  end

  describe 'GET /bookings/:id' do
    it 'returns a single booking' do
      booking = setup_show

      get "/api/bookings/#{booking.id}"

      verify_show
    end

    it 'returns a single booking serialized by json_api' do
      booking = setup_show

      get "/api/bookings/#{booking.id}",
          headers: jsonapi_headers

      verify_show
    end
  end

  describe 'POST /bookings' do
    context 'when params are valid' do
      let(:valid_params) do
        flight = create(:flight)
        user = create(:user)
        { no_of_seats: 20,
          seat_price: 30,
          flight_id: flight.id,
          user_id: user.id }
      end

      it 'creates a booking' do
        post_new(valid_params)

        expect(response).to have_http_status(:created)
        expect(Booking.count).to eq(1)
        booking = Booking.all.first
        expect(booking.no_of_seats).to eq(valid_params[:no_of_seats])
        expect(booking.seat_price).to eq(valid_params[:seat_price])
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { no_of_seats: 0 }
      end

      it 'returns 400 Bad Request' do
        post_new(invalid_params)

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('no_of_seats', 'seat_price', 'flight', 'user')
        expect(Booking.count).to eq(0)
      end
    end
  end

  describe 'updating bookings' do
    let(:no_of_seats) { 25 }
    let(:old_seat_price) { 30 }
    let(:new_seat_price) { 65 }
    let(:update_params) { { seat_price: new_seat_price } }
    let(:booking) { create(:booking, no_of_seats: no_of_seats, seat_price: old_seat_price) }

    it 'sends PUT /bookings/:id request' do
      put "/api/bookings/#{booking.id}",
          params: { booking: update_params }.to_json,
          headers: api_headers

      verify_update(Booking.find(booking.id), new_seat_price, no_of_seats)
    end

    it 'sends PATCH /bookings/:id request' do
      patch "/api/bookings/#{booking.id}",
            params: { booking: update_params }.to_json,
            headers: api_headers

      verify_update(Booking.find(booking.id), new_seat_price, no_of_seats)
    end
  end

  describe 'DELETE /bookings/:id' do
    it 'deletes a booking' do
      booking = create(:booking)

      delete "/api/bookings/#{booking.id}"

      expect(response).to have_http_status(:no_content)
      expect(Booking.all.length).to eq(0)
    end
  end

  def post_new(booking_params)
    post  '/api/bookings',
          params: { booking: booking_params }.to_json,
          headers: api_headers
  end

  def setup_show
    create(:booking)
  end

  def verify_show
    expect(json_body['booking']).to include('no_of_seats', 'seat_price', 'flight', 'user')
  end

  def setup_index
    create_list(:booking, 3)
  end

  def verify_update(booking, seat_price, no_of_seats)
    expect(response).to have_http_status(:ok)
    expect(booking.seat_price).to eq(seat_price)
    expect(booking.no_of_seats).to eq(no_of_seats)
  end
end
