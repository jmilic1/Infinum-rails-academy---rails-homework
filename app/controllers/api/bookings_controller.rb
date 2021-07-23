module Api
  class BookingsController < ApplicationController
    # rubocop:disable Layout/LineLength
    def index
      user = find_user_by_token
      return render json: { errors: 'No user with such token exists' }, status: :bad_request if user.nil?

      if request.headers['x_api_serializer_root'] == '0'
        render json: BookingSerializer.render_as_hash(Booking.where(user.id), view: :extended), status: :ok
      else
        render json: { bookings: BookingSerializer.render_as_hash(Booking.(user.id), view: :extended) }, status: :ok
      end
    end

    def create
      booking = Booking.new(booking_params)

      if booking.save
        render json: { booking: BookingSerializer.render_as_hash(booking, view: :extended) }, status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end
    # rubocop:enable Layout/LineLength

    def show
      booking = Booking.find(params[:id])

      if booking.nil?
        return render json: { errors: 'Booking with such id does not exist' }, status: :bad_request
      end

      # rubocop:disable Layout/LineLength
      if request.headers['x_api_serializer'] == 'json_api'
        render json: { booking: JsonApi::BookingSerializer.new(booking).serializable_hash.to_json }, status: :ok
      else
        render json: { booking: BookingSerializer.render_as_hash(booking, view: :extended) }, status: :ok
      end
      # rubocop:enable Layout/LineLength
    end

    def update
      booking = Booking.find(params[:id])

      if booking.nil?
        return render json: { errors: 'Booking with such id does not exist' }, status: :bad_request
      end

      if booking.update(booking_params)
        # rubocop:disable Layout/LineLength
        render json: { booking: BookingSerializer.render_as_hash(booking, view: :extended) }, status: :ok
        # rubocop:enable Layout/LineLength
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def destroy
      booking = Booking.find(params[:id])

      if booking.nil?
        return render json: { errors: 'Booking with such id does not exist' }, status: :bad_request
      end

      if booking.destroy
        render json: {}, status: :no_content
      else
        render json: { errors: errors }, status: :bad_request
      end
    end

    private

    def get_booking(id)
      booking = Booking.find(id)

      if booking.nil?
        render json: { errors: 'Booking with such id does not exist' }, status: :bad_request
      else
        # rubocop:disable Layout/LineLength
        render json: { booking: UserSerializer.render(booking, view: :extended).serializable_hash }, status: :ok
        # rubocop:enable Layout/LineLength
      end
    end

    def booking_params
      params.require(:booking).permit(:no_of_seats, :seat_price, :flight_id, :user_id)
    end

    def find_user_by_token
      User.find_by(token: request.headers['Authorization'])
    end
  end
end
