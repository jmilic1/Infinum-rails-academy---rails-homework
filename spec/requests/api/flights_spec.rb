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
    it 'successfully returns a list of flights' do
      setup_index

      get '/api/flights'

      expect(response).to have_http_status(:ok)
      expect(json_body['flights'].length).to equal(3)
    end

    it 'returns a list of flights without root' do
      setup_index

      get '/api/flights',
          headers: root_headers('0')

      expect(response).to have_http_status(:ok)
      expect(json_body.length).to equal(3)
    end
  end

  describe 'GET /flights/:id' do
    it 'returns a single flights' do
      flight = setup_show

      get "/api/flights/#{flight.id}"

      verify_show
    end

    it 'returns a single flight serialized by json_api' do
      flight = setup_show

      get "/api/flights/#{flight.id}",
          headers: jsonapi_headers

      verify_show
    end
  end

  describe 'POST /flights' do
    context 'when params are valid' do
      let(:valid_params) do
        company = create(:company)
        { name: 'Minas Tirith - Minas Morgul',
          no_of_seats: 20,
          base_price: 30,
          departs_at: 10.days.after,
          arrives_at: 11.days.after,
          company_id: company.id }
      end

      it 'creates a flight' do
        post_new(valid_params, admin_token)

        expect(response).to have_http_status(:created)
        expect(Flight.count).to eq(1)
        flight = Flight.all.first
        expect(flight.name).to eq(valid_params[:name])
        expect(flight.no_of_seats).to eq(valid_params[:no_of_seats])
        expect(flight.base_price).to eq(valid_params[:base_price])
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { no_of_seats: 0 }
      end

      it 'returns 400 Bad Request' do
        post_new(invalid_params, admin_token)

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name',
                                               'no_of_seats',
                                               'base_price',
                                               'departs_at',
                                               'arrives_at',
                                               'company')
        expect(Flight.count).to eq(0)
      end
    end
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe 'updating flights' do
    let(:name) { 'Zagreb - Split' }
    let(:old_no_of_seats) { 10 }
    let(:new_no_of_seats) { 32 }
    let(:update_params) { { no_of_seats: new_no_of_seats } }
    let(:flight) { create(:flight, name: name, no_of_seats: old_no_of_seats) }

    it 'sends PUT /flights/:id request' do
      put "/api/flights/#{flight.id}",
          params: { flight: update_params }.to_json,
          headers: auth_headers(admin_token)

      verify_update(Flight.find(flight.id), name, new_no_of_seats)
    end

    it 'sends PATCH /flights/:id request' do
      patch "/api/flights/#{flight.id}",
          params: { flight: update_params }.to_json,
          headers: auth_headers(admin_token)

      verify_update(Flight.find(flight.id), name, new_no_of_seats)
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  describe 'DELETE /flights/:id' do
    it 'deletes a flight' do
      flight = create(:flight)

      delete "/api/flights/#{flight.id}",
             headers: auth_headers(admin_token)

      expect(response).to have_http_status(:no_content)
      expect(Flight.all.length).to eq(0)
    end
  end

  def post_new(flight_params, token)
    post  '/api/flights',
          params: { flight: flight_params }.to_json,
          headers: auth_headers(token)
  end

  def setup_show
    create(:flight)
  end

  def verify_show
    expect(json_body['flight']).to include('name',
                                           'no_of_seats',
                                           'base_price',
                                           'departs_at',
                                           'arrives_at')
  end

  def setup_index
    create_list(:flight, 3)
  end

  def verify_update(flight, name, no_of_seats)
    expect(response).to have_http_status(:ok)
    expect(flight.name).to eq(name)
    expect(flight.no_of_seats).to eq(no_of_seats)
  end
end
