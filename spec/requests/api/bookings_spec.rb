RSpec.describe 'Bookings API', type: :request do
  include TestHelpers::JsonResponse

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
    let!(:booking) { create(:booking) }

    context 'when booking id exists' do
      it 'returns a single booking' do
        get "/api/bookings/#{booking.id}"

        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('no_of_seats', 'seat_price', 'flight', 'user')
      end

      it 'returns a single booking serialized by json_api' do
        get "/api/bookings/#{booking.id}",
            headers: jsonapi_headers

        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('no_of_seats', 'seat_price', 'flight', 'user')
      end
    end

    context 'when booking id does not exist' do
      it 'returns errors' do
        get '/api/bookings/1'

        expect(response).to have_http_status(:not_found)
        expect(json_body).to include('errors')
      end
    end
  end

  describe 'POST /bookings' do
    context 'when params are valid' do
      let(:valid_params) do
        { no_of_seats: 20,
          seat_price: 30,
          flight_id: create(:flight).id,
          user_id: create(:user).id }
      end

      it 'returns status code 201 (created)' do
        post  '/api/bookings',
              params: { booking: valid_params }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:created)
      end

      it 'creates a booking' do
        post  '/api/bookings',
              params: { booking: valid_params }.to_json,
              headers: api_headers

        expect(Booking.count).to eq(1)
      end

      it 'assigns correct values to created booking' do
        post  '/api/bookings',
              params: { booking: valid_params }.to_json,
              headers: api_headers

        booking = Booking.first
        expect(booking.no_of_seats).to eq(valid_params[:no_of_seats])
        expect(booking.seat_price).to eq(valid_params[:seat_price])
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { no_of_seats: 0 }
      end

      it 'returns 400 Bad Request' do
        post  '/api/bookings',
              params: { booking: invalid_params }.to_json,
              headers: api_headers

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns errors for all invalid attributes' do
        post  '/api/bookings',
              params: { booking: invalid_params }.to_json,
              headers: api_headers

        expect(json_body['errors']).to include('no_of_seats', 'seat_price', 'flight', 'user')
      end

      it 'does not create booking' do
        post  '/api/bookings',
              params: { booking: invalid_params }.to_json,
              headers: api_headers

        expect(Booking.count).to eq(0)
      end
    end
  end

  describe 'updating bookings' do
    let(:update_params) { { seat_price: 65 } }

    context 'when id does not exist' do
      it 'returns errors' do
        put '/api/bookings/1',
            params: { booking: update_params }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:not_found)
        expect(json_body).to include('errors')
      end
    end

    context 'when id exists' do
      let!(:booking) { create(:booking, no_of_seats: 25, seat_price: 30) }

      it 'updates specified values' do
        put "/api/bookings/#{booking.id}",
            params: { booking: update_params }.to_json,
            headers: api_headers

        updated_booking = booking.reload
        expect(updated_booking.seat_price).to eq(65)
        expect(updated_booking.no_of_seats).to eq(25)
      end

      it 'returns status 200 (ok)' do
        put "/api/bookings/#{booking.id}",
            params: { booking: update_params }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:ok)
      end
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
end
