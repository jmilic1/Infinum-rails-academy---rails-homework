module Api
  class BookingsController < ApplicationController
    def index
      common_index(BookingSerializer, Booking, :bookings)
    end

    def create
      booking = Booking.new(booking_params)

      if booking.save
        render json: BookingSerializer.render(booking, view: :extended, root: :booking),
               status: :created
      else
        render_bad_request(booking)
      end
    end

    def show
      booking = Booking.find(params[:id])

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { booking: JsonApi::BookingSerializer.new(booking).serializable_hash.to_json },
               status: :ok
      else
        render json: BookingSerializer.render(booking, view: :extended, root: :booking), status: :ok
      end
    end

    def update
      booking = Booking.find(params[:id])

      if booking.update(booking_params)
        render json: BookingSerializer.render(booking, view: :extended, root: :booking), status: :ok
      else
        render_bad_request(booking)
      end
    end

    def destroy
      booking = Booking.find(params[:id])

      if booking.destroy
        render json: {}, status: :no_content
      else
        render_bad_request(booking)
      end
    end

    private

    def booking_params
      params.require(:booking).permit(:no_of_seats, :seat_price, :flight_id, :user_id)
    end
  end
end
