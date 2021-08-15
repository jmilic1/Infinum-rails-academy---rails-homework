RSpec.describe 'Flights API', type: :request do
  include TestHelpers::JsonResponse
  let!(:admin) { create(:user, token: 'admin-token', role: 'admin') }
  let!(:public) { create(:user, token: 'public-token') }

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

    it 'returns sorted flights' do
      get '/api/flights'

      flights = json_body['flights']
      (0..flights.length - 2).step do |index|
        expect(less_than_or_equal(flights[index], flights[index + 1])).to be true
      end
    end

    context 'when inactive flights exist' do
      before { create_list(:flight, 3, departs_at: 1.day.ago) }

      it 'returns only active flights' do
        get '/api/flights'

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].length).to equal(3)

        json_body['flights'].each do |flight|
          expect(Time.zone.parse(flight['departs_at'])).to be > Time.zone.now
        end
      end
    end

    it 'returns number of booked seats for each flight' do
      get '/api/flights'

      flights = json_body['flights']
      booked_seats = flights.map do |flight|
        flight['bookings'].inject(0) do |sum, booking|
          sum + booking['no_of_seats'].to_i
        end
      end

      (0..flights.length - 1).step do |index|
        expect(flights[index]['no_of_booked_seats'].to_i).to eq(booked_seats[index])
      end
    end

    it 'returns company name for each flight' do
      get '/api/flights'

      flights = json_body['flights']
      company_names = flights.map do |flight|
        flight['company']['name']
      end

      (0..flights.length - 1).step do |index|
        expect(flights[index]['company_name']).to eq(company_names[index])
      end
    end

    context 'when using filter' do
      let(:departure) { 42.days.after }

      before do
        create(:flight, name: 'great eagles')
        create(:flight, name: 'great EAGLES')
        create(:flight, departs_at: departure, arrives_at: 43.days.after)
        booking = create(:booking, no_of_seats: 5)
        create(:flight, bookings: [booking], no_of_seats: 10)
      end

      it 'filters by name' do
        get '/api/flights?name_cont=eagles'

        json_body['flights'].each do |flight|
          expect(flight['name'].downcase).to include('eagles')
        end
      end

      it 'filters by departure' do
        get "/api/flights?departs_at_eq=#{departure}"

        json_body['flights'].each do |flight|
          expect(Time.zone.parse(flight['departs_at']).to_i).to eq(departure.to_i)
        end
      end

      it 'filters by available seats' do
        get '/api/flights?no_of_available_seats_gteq=5'

        json_body['flights'].each do |flight|
          available_seats = flight['no_of_seats'] - flight['no_of_booked_seats']
          expect(available_seats).to be >= 5
        end
      end

      it 'filters by name and departure' do
        get "/api/flights?name_cont=eagles&departs_at_eq=#{departure}"

        json_body['flights'].each do |flight|
          expect(flight['name'].downcase).to include('eagles')
          expect(Time.zone.parse(flight['departs_at']).to_i).to eq(departure.to_i)
        end
      end

      it 'filters by name and available seats' do
        get '/api/flights?name_cont=eagles&no_of_available_seats_gteq=5'

        json_body['flights'].each do |flight|
          expect(flight['name'].downcase).to include('eagles')

          available_seats = flight['no_of_seats'] - flight['no_of_booked_seats']
          expect(available_seats).to be >= 5
        end
      end

      it 'filters by departure and available seats' do
        get "/api/flights?departs_at_eq=#{departure}&no_of_available_seats_gteq=5"

        json_body['flights'].each do |flight|
          expect(Time.zone.parse(flight['departs_at']).to_i).to eq(departure.to_i)

          available_seats = flight['no_of_seats'] - flight['no_of_booked_seats']
          expect(available_seats).to be >= 5
        end
      end

      it 'filters by name, departure and available seats' do
        get "/api/flights?name_cont=eagles&departs_at_eq=#{departure}&no_of_available_seats_gteq=5"

        json_body['flights'].each do |flight|
          expect(flight['name'].downcase).to include('eagles')
          expect(Time.zone.parse(flight['departs_at']).to_i).to eq(departure.to_i)

          available_seats = flight['no_of_seats'] - flight['no_of_booked_seats']
          expect(available_seats).to be >= 5
        end
      end
    end
  end

  describe 'current price of flight' do
    let!(:price_helper) do
      { older16: create(:flight, departs_at: 16.days.ago, base_price: 10),
        older12: create(:flight, departs_at: 12.days.ago, base_price: 10),
        older5: create(:flight, departs_at: 5.days.ago, base_price: 10),
        older0: create(:flight, departs_at: 5.minutes.ago, base_price: 10) }
    end

    # rubocop:disable RSpec/ExampleLength
    it 'returns correct current prices' do
      get '/api/flights'

      flights = json_body['flights']
      flights.each do |flight|
        case flight['id'].to_i
        when price_helper[:older16].id
          expect(flight['current_price'].to_i).to eq(price_helper[:older16].base_price)
        when price_helper[:older12].id
          difference = (flight.departs_at - Time.zone.now).to_i / 1.day
          expected = ((2 - difference.to_f / 15) * flight.base_price).round
          expect(flight['current_price'].to_i).to eq(expected)
        when price_helper[:older5].id
          difference = (flight.departs_at - Time.zone.now).to_i / 1.day
          expected = ((2 - difference.to_f / 15) * flight.base_price).round
          expect(flight['current_price'].to_i).to eq(expected)
        when price_helper[:older0].id
          expect(flight['current_price'].to_i).to eq(price_helper[:older16].base_price * 2)
        else
          pass
        end
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe 'GET /flights/:id' do
    let!(:flight) { create(:flight) }

    context 'when flight id exists' do
      it 'returns a single flight' do
        get "/api/flights/#{flight.id}"

        expect(response).to have_http_status(:ok)
        expect(json_body['flight']).to include('name',
                                               'no_of_seats',
                                               'base_price',
                                               'departs_at',
                                               'arrives_at')
      end

      it 'returns a single flight serialized by json_api' do
        get "/api/flights/#{flight.id}",
            headers: jsonapi_headers

        expect(response).to have_http_status(:ok)
        expect(json_body['flight']).to include('name',
                                               'no_of_seats',
                                               'base_price',
                                               'departs_at',
                                               'arrives_at')
      end
    end

    context 'when flight id does not exist' do
      it 'returns errors' do
        get '/api/flights/1'

        expect(response).to have_http_status(:not_found)
        expect(json_body).to include('errors')
      end
    end
  end

  describe 'POST /flights' do
    context 'when params are valid' do
      let(:valid_params) do
        { name: 'Minas Tirith - Minas Morgul',
          no_of_seats: 20,
          base_price: 30,
          departs_at: 10.days.after,
          arrives_at: 11.days.after,
          company_id: create(:company).id }
      end

      it 'returns status code 201 (created) if admin sends POST request' do
        post  '/api/flights',
              params: { flight: valid_params }.to_json,
              headers: auth_headers(admin)

        expect(response).to have_http_status(:created)
      end

      it 'creates a flight if admin sends POST request' do
        post  '/api/flights',
              params: { flight: valid_params }.to_json,
              headers: auth_headers(admin)

        expect(Flight.count).to eq(1)
      end

      it 'assigns correct values to created flight if admin sends POST request' do
        post  '/api/flights',
              params: { flight: valid_params }.to_json,
              headers: auth_headers(admin)

        flight = Flight.first
        expect(flight.name).to eq(valid_params[:name])
        expect(flight.no_of_seats).to eq(valid_params[:no_of_seats])
        expect(flight.base_price).to eq(valid_params[:base_price])
      end

      it 'returns status code 403 forbidden if public user sends POST request' do
        post  '/api/flights',
              params: { flight: valid_params }.to_json,
              headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end

      it 'does not create a flight if public user sends POST request' do
        post  '/api/flights',
              params: { flight: valid_params }.to_json,
              headers: auth_headers(public)

        expect(Flight.count).to eq(0)
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { no_of_seats: 0 }
      end

      it 'returns 400 Bad Request' do
        post  '/api/flights',
              params: { flight: invalid_params }.to_json,
              headers: auth_headers(admin)

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns errors for all invalid attributes' do
        post  '/api/flights',
              params: { flight: invalid_params }.to_json,
              headers: auth_headers(admin)

        expect(json_body['errors']).to include('name',
                                               'no_of_seats',
                                               'base_price',
                                               'departs_at',
                                               'arrives_at',
                                               'company')
      end

      it 'does not create flight' do
        post  '/api/flights',
              params: { flight: invalid_params }.to_json,
              headers: auth_headers(admin)

        expect(Flight.count).to eq(0)
      end
    end
  end

  describe 'PUT /flights' do
    let(:update_params) { { no_of_seats: 32 } }

    context 'when id does not exist' do
      it 'returns errors' do
        put '/api/flights/1',
            params: { flight: update_params }.to_json,
            headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
        expect(json_body).to include('errors')
      end
    end

    context 'when id exists' do
      let!(:flight) { create(:flight, name: 'Zagreb - Split', no_of_seats: 10) }

      it 'returns status code 200 ok if admin sends PUT request' do
        put "/api/flights/#{flight.id}",
            params: { flight: update_params }.to_json,
            headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
      end

      it 'updates specified values if admin sends PUT request' do
        put "/api/flights/#{flight.id}",
            params: { flight: update_params }.to_json,
            headers: auth_headers(admin)

        updated_flight = flight.reload
        expect(updated_flight.name).to eq('Zagreb - Split')
        expect(updated_flight.no_of_seats).to eq(32)
      end

      it 'returns status code 403 forbidden if public user sends PUT request' do
        put "/api/flights/#{flight.id}",
            params: { flight: update_params }.to_json,
            headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end

      it 'does not update the flight if public user sends PUT request' do
        put "/api/flights/#{flight.id}",
            params: { flight: update_params }.to_json,
            headers: auth_headers(public)

        expect(flight.reload.no_of_seats).to eq(flight.no_of_seats)
      end
    end
  end

  describe 'DELETE /flights/:id' do
    context 'when id does not exist' do
      it 'returns status not found' do
        delete '/api/flights/1',
               headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when admin deletes a flight' do
      let!(:flight) { create(:flight) }

      it 'deletes a flight' do
        delete "/api/flights/#{flight.id}",
               headers: auth_headers(admin)

        expect(response).to have_http_status(:no_content)
        expect(Flight.all.length).to eq(0)
      end
    end

    context 'when public user deletes a flight' do
      let!(:flight) { create(:flight) }

      it 'returns 403 forbidden' do
        delete "/api/flights/#{flight.id}",
               headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end

      it 'does not delete the flight' do
        delete "/api/flights/#{flight.id}",
               headers: auth_headers(public)

        expect(Flight.all.length).to eq(1)
      end
    end
  end

  private

  def created_at_greater?(first, second)
    Time.zone.parse(first['created_at']) > Time.zone.parse(second['created_at'])
  end

  def name_greater?(first, second)
    first['name'] > second['name']
  end

  def less_than_or_equal(first, second)
    first_departs_at = Time.zone.parse(first['departs_at'])
    second_departs_at = Time.zone.parse(second['departs_at'])
    return false if first_departs_at > second_departs_at

    if first_departs_at == second_departs_at &&
       (name_greater?(first, second) ||
         (first['name'] == second['name'] && created_at_greater?(first, second)))
      return false
    end

    true
  end
end
