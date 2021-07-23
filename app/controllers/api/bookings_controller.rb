module Api
  class BookingsController < ApplicationController
    # rubocop:disable Metrics/MethodLength
    def index
      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: BookingSerializer.render(Booking.all, view: :extended),
               status: :ok
      else
        render json: { bookings: BookingSerializer.render(Booking.all, view: :extended) },
               status: :ok
      end
    end

    def create
      booking = Booking.new(booking_params)

      if booking.save
        render json: { booking: BookingSerializer.render(booking, view: :extended) },
               status: :created
      else
        render json: { errors: booking.errors },
               status: :bad_request
      end
    end

    def show
      booking = Booking.find(params[:id])
      if booking.nil?
        return render json: { errors: 'Booking with such id does not exist' }, status: :bad_request
      end

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { booking: JsonApi::BookingSerializer.new(booking).serializable_hash.to_json },
               status: :ok
      else
        render json: { booking: BookingSerializer.render_as_hash(booking, view: :extended) },
               status: :ok
      end
    end

    def update
      booking = Booking.find(params[:id])

      if booking.nil?
        return render json: { errors: 'Booking with such id does not exist' },
                      status: :bad_request
      end

      if booking.update(booking_params)
        render json: { booking: BookingSerializer.render_as_hash(booking, view: :extended) },
               status: :ok
      else
        render json: { errors: booking.errors },
               status: :bad_request
      end
    end

    def destroy
      booking = Booking.find(params[:id])

      if booking.nil?
        return render json: { errors: 'Booking with such id does not exist' },
                      status: :bad_request
      end

      if booking.destroy
        render json: {},
               status: :no_content
      else
        render json: { errors: errors },
               status: :bad_request
      end
    end

    private

    def get_booking(id)
      booking = Booking.find(id)

      if booking.nil?
        render json: { errors: 'Booking with such id does not exist' },
               status: :bad_request
      else
        render json: { booking: UserSerializer.render(booking, view: :extended).serializable_hash },
               status: :ok
      end
    end
    # rubocop:enable Metrics/MethodLength

    def booking_params
      params.require(:booking).permit(:no_of_seats, :seat_price, :flight_id, :user_id)
    end
  end
end
