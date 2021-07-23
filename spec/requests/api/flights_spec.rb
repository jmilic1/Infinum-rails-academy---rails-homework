RSpec.describe 'Flights API', type: :request do
  include TestHelpers::JsonResponse
  let(:company) { create(:company) }
  let(:admin_token) { 'admin-token' }
  let(:public_token) { 'public-token' }

  before do
    create(:user, token: admin_token, role: 'admin')
    create(:user, token: public_token, role: 'public')
  end

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

      expect(json_body['flight']).to include('no_of_seats')
    end

    it 'returns a single flight serialized by json_api' do
      get "/api/flights/#{flight.id}",
          headers: jsonapi_headers

      expect(json_body['flight']).to include('no_of_seats')
    end
  end

  describe 'POST /flights' do
    let(:company) { create(:company) }

    context 'when params are valid' do
      it 'creates a flight' do
        name = 'Minas Tirith - Minas Morgul'
        no_of_seats = 25
        base_price = 12
        id = post_new_id(name, no_of_seats, base_price, 10.days.after, 11.days.after)

        get "/api/flights/#{id}"

        expect(json_body['flight']).to include('id' => id,
                                               'name' => name,
                                               'no_of_seats' => no_of_seats,
                                               'base_price' => base_price)
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/flights',
             params: { flight: { no_of_seats: 0 } }.to_json,
             headers: auth_headers(admin_token)

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('no_of_seats')
      end
    end
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe 'updating flights' do
    let(:name) { 'Zagreb - Split' }
    let(:old_no_of_seats) { 10 }
    let(:base_price) { 10 }
    let(:new_no_of_seats) { 32 }

    it 'sends PUT /flights/:id request' do
      id = post_new_id(name, old_no_of_seats, base_price,
                       1.day.after, 2.days.after)

      put "/api/flights/#{id}",
          params: { flight: { no_of_seats: new_no_of_seats } }.to_json,
          headers: auth_headers(admin_token)

      expect(response).to have_http_status(:ok)
      expect(json_body['flight']).to include('id' => id,
                                             'name' => name,
                                             'no_of_seats' => new_no_of_seats,
                                             'base_price' => base_price)
    end

    it 'sends PATCH /flights/:id request' do
      id = post_new_id(name, old_no_of_seats, base_price,
                       1.day.after, 2.days.after)

      patch "/api/flights/#{id}",
            params: { flight: { no_of_seats: new_no_of_seats } }.to_json,
            headers: auth_headers(admin_token)

      expect(response).to have_http_status(:ok)
      expect(json_body['flight']).to include('id' => id,
                                             'name' => name,
                                             'no_of_seats' => new_no_of_seats,
                                             'base_price' => base_price)
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  describe 'DELETE /flights/:id' do
    it 'deletes a flight' do
      id = post_new_id('Zagreb - Split',
                       10,
                       10,
                       1.day.after,
                       2.days.after)

      delete "/api/flights/#{id}",
             headers: auth_headers(admin_token)

      expect(response).to have_http_status(:no_content)

      get "/api/flights/#{id}"

      expect(response).to have_http_status(:not_found)
    end
  end

  def post_new_id(name, no_of_seats, base_price, departs_at, arrives_at)
    post  '/api/flights',
          params: { flight: { name: name,
                              no_of_seats: no_of_seats,
                              base_price: base_price,
                              departs_at: departs_at,
                              arrives_at: arrives_at,
                              company_id: company.id } }.to_json,
          headers: auth_headers(admin_token)

    json_body['flight']['id']
  end
end
