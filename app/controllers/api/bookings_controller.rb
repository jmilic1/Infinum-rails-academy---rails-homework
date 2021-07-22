module Api
  class BookingsController < ApplicationController
    def index
      render json: { bookings: BookingSerializer.render(Booking.all) }, status: :ok
    end

    def create
      booking = Booking.new(booking_params)

      if booking.save
        render json: { booking: BookingSerializer.render(booking) }, status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def show
      booking = Booking.find(params[:id])

      if booking.nil?
        return render json: { errors: 'Booking with such id does not exist' }, status: :bad_request
      end

      # rubocop:disable Layout/LineLength
      if request.headers['x_api_serializer'] == 'json_api'
        render json: { booking: JsonApi::BookingSerializer.new(booking).serializable_hash.to_json }, status: :ok
      else
        render json: { booking: BookingSerializer.render(booking) }, status: :ok
      end
      # rubocop:enable Layout/LineLength
    end

    def update
      booking = Booking.find(params[:id])

      if booking.nil?
        return render json: { errors: 'Booking with such id does not exist' }, status: :bad_request
      end

      if booking.update(booking_params)
        render json: {}, status: :no_content
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
        render json: { booking: UserSerializer.render(booking) }, status: :ok
      end
    end

    def booking_params
      params.require(:booking).permit(:no_of_seats, :seat_price, :flight_id, :user_id)
    end
  end
end
