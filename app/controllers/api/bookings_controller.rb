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
      common_update(BookingSerializer, Booking, booking_params, :booking)
    end

    def destroy
      common_destroy(Booking)
    end

    private

    def booking_params
      params.require(:booking).permit(:no_of_seats, :seat_price, :flight_id, :user_id)
    end
  end
end
