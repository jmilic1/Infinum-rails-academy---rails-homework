RSpec.describe 'Bookings API', type: :request do
  include TestHelpers::JsonResponse
  let(:admin) { create(:user, token: 'admin-token', role: 'admin') }
  let!(:public) { create(:user, token: 'public-token') }

  describe 'GET /bookings' do
    before do
      create_list(:booking, 3, user: admin)
      create_list(:booking, 3, user: public)
    end

    it 'returns 403 unauthorized if user is not authenticated' do
      get '/api/bookings'

      expect(response).to have_http_status(:unauthorized)
      expect(json_body['errors']).to include('token')
    end

    context 'when admin requests index' do
      it 'successfully returns a list of all bookings' do
        get '/api/bookings',
            headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].length).to equal(6)
      end

      it 'returns a list of all bookings without root' do
        get '/api/bookings',
            headers: auth_headers(admin).merge(root_headers('0'))

        expect(response).to have_http_status(:ok)
        expect(json_body.length).to equal(6)
      end
    end

    context 'when public user requests index' do
      it 'successfully returns a list of their bookings' do
        get '/api/bookings',
            headers: auth_headers(public)

        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].length).to equal(3)

        json_body['bookings'].each { |booking| expect(booking['user']['id']).to eq(public.id) }
      end

      it 'returns a list of their bookings without root' do
        get '/api/bookings',
            headers: auth_headers(public).merge(root_headers('0'))

        expect(response).to have_http_status(:ok)
        expect(json_body.length).to equal(3)

        json_body.each { |booking| expect(booking['user']['id']).to eq(public.id) }
      end
    end
  end

  describe 'GET /bookings/:id' do
    it 'returns 403 unauthorized if user is not authenticated' do
      booking = create(:booking)
      get "/api/bookings/#{booking.id}"

      expect(response).to have_http_status(:unauthorized)
      expect(json_body['errors']).to include('token')
    end

    context 'when admin requests booking id' do
      it 'returns any booking' do
        booking = create(:booking)
        get "/api/bookings/#{booking.id}",
            headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('no_of_seats', 'seat_price', 'flight', 'user')
      end

      it 'returns any booking serialized by json_api' do
        booking = create(:booking)
        get "/api/bookings/#{booking.id}",
            headers: jsonapi_headers.merge(auth_headers(admin))

        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('no_of_seats', 'seat_price', 'flight', 'user')
      end

      it 'returns errors if id does not exist' do
        get '/api/bookings/1',
            headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
        expect(json_body).to include('errors')
      end
    end

    context 'when public user requests booking id' do
      it 'returns their booking' do
        user_booking = create(:booking, user: public)

        get "/api/bookings/#{user_booking.id}",
            headers: auth_headers(public)

        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('no_of_seats', 'seat_price', 'flight', 'user')
      end

      it "fails to retrieve another user's booking" do
        booking = create(:booking)
        get "/api/bookings/#{booking.id}",
            headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
      end

      it 'returns error if id does not exist' do
        get '/api/bookings/1',
            headers: auth_headers(public)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /bookings' do
    let(:valid_params_public) do
      { no_of_seats: 20,
        seat_price: 30,
        flight_id: create(:flight).id,
        user_id: public.id }
    end

    let(:valid_params_admin) do
      { no_of_seats: 20,
        seat_price: 30,
        flight_id: create(:flight).id,
        user_id: admin.id }
    end

    it 'returns 401 unauthorized if user is not authenticated' do
      post  '/api/bookings',
            params: { booking: valid_params_public }.to_json,
            headers: api_headers

      expect(response).to have_http_status(:unauthorized)
    end

    context 'when admin posts new booking' do
      it 'returns status code 201 (created)' do
        post  '/api/bookings',
              params: { booking: valid_params_admin }.to_json,
              headers: auth_headers(admin)

        expect(response).to have_http_status(:created)
      end

      it 'creates new booking for admin' do
        expect do
          post '/api/bookings', params: { booking: valid_params_admin }.to_json,
                                headers: auth_headers(admin)

        end.to(change { admin.bookings.count }.by(1))
      end

      it 'creates new booking for public user' do
        expect do
          post '/api/bookings', params: { booking: valid_params_public }.to_json,
                                headers: auth_headers(admin)

        end.to(change { public.bookings.count }.by(1))
      end

      it 'assigns correct values to created booking' do
        post  '/api/bookings',
              params: { booking: valid_params_admin }.to_json,
              headers: auth_headers(admin)

        booking = Booking.first
        expect(booking.no_of_seats).to eq(valid_params_admin[:no_of_seats])
        expect(booking.seat_price).to eq(valid_params_admin[:seat_price])
      end
    end

    context 'when public user posts new booking' do
      it 'returns status code 201 (created)' do
        post  '/api/bookings',
              params: { booking: valid_params_public }.to_json,
              headers: auth_headers(public)

        expect(response).to have_http_status(:created)
      end

      it 'creates new booking for public user' do
        expect do
          post '/api/bookings', params: { booking: valid_params_public }.to_json,
                                headers: auth_headers(public)

        end.to(change { public.bookings.count }.by(1))
      end

      it 'ignores user_id parameter' do
        expect do
          post '/api/bookings', params: { booking: valid_params_admin }.to_json,
                                headers: auth_headers(public)

        end.to(change { public.bookings.count }.by(1))
      end

      it 'assigns correct values to created booking' do
        post  '/api/bookings',
              params: { booking: valid_params_public }.to_json,
              headers: auth_headers(public)

        booking = Booking.first
        expect(booking.no_of_seats).to eq(valid_params_public[:no_of_seats])
        expect(booking.seat_price).to eq(valid_params_public[:seat_price])
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { no_of_seats: 0 }
      end

      it 'returns 400 Bad Request' do
        post  '/api/bookings',
              params: { booking: invalid_params }.to_json,
              headers: auth_headers(admin)

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns errors for all invalid attributes' do
        post  '/api/bookings',
              params: { booking: invalid_params }.to_json,
              headers: auth_headers(admin)

        expect(json_body['errors']).to include('no_of_seats', 'seat_price', 'flight')
      end

      it 'does not create booking' do
        post  '/api/bookings',
              params: { booking: invalid_params }.to_json,
              headers: auth_headers(admin)

        expect(Booking.count).to eq(0)
      end
    end
  end

  describe 'PUT /bookings' do
    let(:update_params) { { seat_price: 65, user_id: public.id } }
    let!(:booking) { create(:booking, no_of_seats: 25, seat_price: 30, user: admin) }

    context 'when id does not exist' do
      it 'returns errors' do
        put '/api/bookings/1',
            params: { booking: update_params }.to_json,
            headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
        expect(json_body).to include('errors')
      end
    end

    context 'when admin updates booking' do
      it 'returns status 200 (ok)' do
        put "/api/bookings/#{booking.id}",
            params: { booking: update_params }.to_json,
            headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
      end

      it 'updates specified values' do
        put "/api/bookings/#{booking.id}",
            params: { booking: update_params }.to_json,
            headers: auth_headers(admin)

        updated_booking = booking.reload
        expect(updated_booking.seat_price).to eq(65)
        expect(updated_booking.no_of_seats).to eq(25)
      end

      it 'updates user id of booking' do
        put "/api/bookings/#{booking.id}",
            params: { booking: update_params }.to_json,
            headers: auth_headers(admin)

        updated_booking = booking.reload
        expect(updated_booking.user.id).to eq(public.id)
      end
    end

    context 'when public user updates booking' do
      let!(:booking_public) { create(:booking, no_of_seats: 25, seat_price: 30, user: public) }

      it 'returns status 200 (ok)' do
        put "/api/bookings/#{booking_public.id}",
            params: { booking: update_params }.to_json,
            headers: auth_headers(public)

        expect(response).to have_http_status(:ok)
      end

      it 'updates specified values' do
        put "/api/bookings/#{booking_public.id}",
            params: { booking: update_params }.to_json,
            headers: auth_headers(public)

        updated_booking = booking_public.reload
        expect(updated_booking.seat_price).to eq(65)
        expect(updated_booking.no_of_seats).to eq(25)
      end

      it 'does not update user id of booking' do
        put "/api/bookings/#{booking_public.id}",
            params: { booking: update_params }.to_json,
            headers: auth_headers(public)

        updated_booking = booking_public.reload
        expect(updated_booking.user.id).to eq(public.id)
      end

      it "returns status 403 forbidden if public user tries to update other user's booking" do
        put "/api/bookings/#{booking.id}",
            params: { booking: update_params }.to_json,
            headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /bookings/:id' do
    context 'when id does not exist' do
      it 'returns status not found' do
        delete '/api/bookings/1',
               headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when admin deletes a booking' do
      let!(:booking_admin) { create(:booking, user: admin) }
      let!(:booking_public) { create(:booking, user: public) }

      it 'deletes an admin booking' do
        delete "/api/bookings/#{booking_admin.id}",
               headers: auth_headers(admin)

        expect(response).to have_http_status(:no_content)
        expect(Booking.all.length).to eq(1)
      end

      it "deletes a public user's booking" do
        delete "/api/bookings/#{booking_public.id}",
               headers: auth_headers(admin)

        expect(response).to have_http_status(:no_content)
        expect(Booking.all.length).to eq(1)
      end
    end

    context 'when public user deletes a booking' do
      let!(:booking_admin) { create(:booking, user: admin) }
      let!(:booking_public) { create(:booking, user: public) }

      it 'does not delete an admin booking' do
        delete "/api/bookings/#{booking_admin.id}",
               headers: auth_headers(public)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource')
        expect(Booking.all.length).to eq(2)
      end

      it "deletes the public user's booking" do
        delete "/api/bookings/#{booking_public.id}",
               headers: auth_headers(public)

        expect(response).to have_http_status(:no_content)
        expect(Booking.all.length).to eq(1)
      end
    end
  end
end
