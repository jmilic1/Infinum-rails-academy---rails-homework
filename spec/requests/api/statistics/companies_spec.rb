RSpec.describe 'Companies Statistics API', type: :request do
  include TestHelpers::JsonResponse
  let!(:admin) { create(:user, token: 'admin-token', role: 'admin') }

  describe 'GET /statistics/companies' do
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
end
