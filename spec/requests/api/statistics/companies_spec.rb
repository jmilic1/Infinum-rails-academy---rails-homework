RSpec.describe 'Companies Statistics API', type: :request do
  include TestHelpers::JsonResponse
  let!(:admin) { create(:user, token: 'admin-token', role: 'admin') }

  describe 'GET /statistics/companies' do
    context 'when indexing' do
      before { create_list(:company, 3) }

      it 'successfully returns a list of companies' do
        get '/api/statistics/companies',
            headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        expect(json_body['companies'].length).to equal(3)
      end

      it 'returns required fields' do
        get '/api/statistics/companies',
            headers: auth_headers(admin)

        expect(json_body['companies']).to all include('company_id', 'total_revenue',
                                                      'total_no_of_booked_seats',
                                                      'average_price_of_seats')
      end
    end

    context 'when checking fields for single company revenue' do
      before do
        company = create(:company)
        first_flight = create(:flight, no_of_seats: 10, departs_at: 1.day.after,
                                       arrives_at: 2.days.after, company: company)

        first_booking = create(:booking, seat_price: 50, no_of_seats: 2, flight: first_flight)
        second_booking = create(:booking, seat_price: 30, no_of_seats: 1, flight: first_flight)
        third_booking = create(:booking, seat_price: 40, no_of_seats: 3, flight: first_flight)

        first_flight.bookings = [first_booking, second_booking, third_booking]

        second_flight = create(:flight, no_of_seats: 50, departs_at: 3.days.after,
                                        arrives_at: 4.days.after, company: company)

        first_booking = create(:booking, seat_price: 30, no_of_seats: 3, flight: second_flight)
        second_booking = create(:booking, seat_price: 25, no_of_seats: 5, flight: second_flight)
        third_booking = create(:booking, seat_price: 45, no_of_seats: 7, flight: second_flight)

        second_flight.bookings = [first_booking, second_booking, third_booking]

        company.flights = [first_flight, second_flight]
      end

      it 'returns correct total revenue' do
        get '/api/statistics/companies',
            headers: auth_headers(admin)

        expect(json_body['companies'][0]['total_revenue']).to eq(2 * 50 + 1 * 30 + 3 * 40 +
                                                                   30 * 3 + 25 * 5 + 45 * 7)
      end

      it 'returns correct total number of booked seats' do
        get '/api/statistics/companies',
            headers: auth_headers(admin)

        expect(json_body['companies'][0]['total_no_of_booked_seats']).to eq(2 + 1 + 3 + 3 + 5 + 7)
      end

      it 'returns correct average price of seats' do
        get '/api/statistics/companies',
            headers: auth_headers(admin)

        company = json_body['companies'][0]
        expect(company['average_price_of_seats']).to eq(company['total_revenue'].to_f /
                                                          company['total_no_of_booked_seats'])
      end
    end
  end
end
