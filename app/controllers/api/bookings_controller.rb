module Api
  class BookingsController < ApplicationController
    def index
      common_index(BookingSerializer, Booking, :bookings)
    end

    def create
      common_create(BookingSerializer, Booking, booking_params, :booking)
    end

    def show
      common_show(JsonApi::BookingSerializer, BookingSerializer, Booking, :booking)
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
