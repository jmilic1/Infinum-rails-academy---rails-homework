module Api
  class BookingsController < ApplicationController
    before_action :authenticate_current_user, only: [:index, :create, :show, :update, :destroy]

    def index
      authorize Booking
      @bookings = policy_scope(filter_bookings.order(:created_at).merge(Flight.order(:departs_at,
                                                                                     :name)))

      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: BookingSerializer.render(@bookings, view: :extended), status: :ok
      else
        render json: BookingSerializer.render(@bookings,
                                              view: :extended, root: :bookings),
               status: :ok
      end
    end

    def create
      authorize Booking
      booking = Booking.new(booking_params)
      booking.user = current_user if booking.user.nil?

      if booking.save
        render json: BookingSerializer.render(booking, view: :extended, root: :booking),
               status: :created
      else
        render_bad_request(booking)
      end
    end

    def show
      @booking = authorize Booking.find(params[:id])

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { booking: JsonApi::BookingSerializer.new(@booking)
                                                          .serializable_hash.to_json },
               status: :ok
      else
        render json: BookingSerializer.render(@booking, view: :extended, root: :booking),
               status: :ok
      end
    end

    def update
      @booking = authorize Booking.find(params[:id])

      if @booking.update(booking_params)
        render json: BookingSerializer.render(@booking, view: :extended, root: :booking),
               status: :ok
      else
        render_bad_request(@booking)
      end
    end

    def destroy
      @booking = authorize Booking.find(params[:id])

      if @booking.destroy
        head :no_content
      else
        render_bad_request(@booking)
      end
    end

    private

    def booking_params
      if current_user.admin?
        params.require(:booking).permit(:no_of_seats, :seat_price, :flight_id, :user_id)
      else
        params.require(:booking).permit(:no_of_seats, :seat_price, :flight_id)
      end
    end

    def filter_bookings
      if request.params['filter'] != 'active'
        Booking.joins(:flight, :user)
      else
        Booking.joins(:flight, :user).where('departs_at > ?', Time.zone.now)
      end
    end
  end
end
