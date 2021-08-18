RSpec.describe 'Flights Statistics API', type: :request do
  include TestHelpers::JsonResponse
  let!(:admin) { create(:user, token: 'admin-token', role: 'admin') }

  describe 'GET /statistics/flights' do
    context 'when indexing' do
      before { create_list(:flight, 3) }

      it 'successfully returns a list of flights' do
        get '/api/statistics/flights',
            headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].length).to equal(3)
      end

      it 'returns required fields' do
        get '/api/statistics/flights',
            headers: auth_headers(admin)

        expect(json_body['flights']).to all include('flight_id', 'revenue', 'no_of_booked_seats',
                                                    'occupancy')
      end
    end

    context 'when checking fields for single flight' do
      before do
        flight = create(:flight, no_of_seats: 10)

        first_booking = create(:booking, seat_price: 50, no_of_seats: 2, flight: flight)
        second_booking = create(:booking, seat_price: 30, no_of_seats: 1, flight: flight)
        third_booking = create(:booking, seat_price: 40, no_of_seats: 3, flight: flight)

        flight.bookings = [first_booking, second_booking, third_booking]
      end

      it 'returns correct revenue' do
        get '/api/statistics/flights',
            headers: auth_headers(admin)

        expect(json_body['flights'][0]['revenue']).to eq(2 * 50 + 1 * 30 + 3 * 40)
      end

      it 'returns correct number of booked seats' do
        get '/api/statistics/flights',
            headers: auth_headers(admin)

        expect(json_body['flights'][0]['no_of_booked_seats']).to eq(2 + 1 + 3)
      end

      it 'returns correct occupancy' do
        get '/api/statistics/flights',
            headers: auth_headers(admin)

        expect(json_body['flights'][0]['occupancy']).to eq("#{(2.to_f + 1 + 3) / 10 * 100}%")
      end
    end
  end
end
