RSpec.describe 'Flights Statistics API', type: :request do
  include TestHelpers::JsonResponse
  let!(:admin) { create(:user, token: 'admin-token', role: 'admin') }

  describe 'GET /statistics/flights' do
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
end
