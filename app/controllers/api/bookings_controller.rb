module Api
  class BookingsController < ApplicationController
    before_action :authenticate_current_user, only: [:index, :create, :show, :update, :destroy]

    def index
      @bookings = Booking.all
      authorize @bookings
      @bookings = policy_scope(Booking)

      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: BookingSerializer.render(@bookings, view: :extended),
               status: :ok
      else
        render json: BookingSerializer.render(@bookings.all, view: :extended, root: :bookings),
               status: :ok
      end
    end

    def create
      user = current_user

      booking = Booking.new(booking_params)
      booking.user_id = user.id

      if booking.save
        render json: BookingSerializer.render(booking, view: :extended, root: :booking),
               status: :created
      else
        render_bad_request(booking)
      end
    end

    def show
      @booking = Booking.find(params[:id])

      authorize @booking
      # @bookings = policy_scope(Booking)
      @booking = policy_scope(@booking)

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
      @booking = Booking.find(params[:id])

      authorize @booking
      # @bookings = policy_scope(Booking)
      @booking = policy_scope(@booking)

      if @booking.update(booking_params)
        render json: BookingSerializer.render(@booking, view: :extended, root: :booking),
               status: :ok
      else
        render_bad_request(@booking)
      end
    end

    def destroy
      @booking = Booking.find(params[:id])

      authorize @booking
      # @bookings = policy_scope(Booking)
      @booking = policy_scope(@booking)

      if @booking.destroy
        head :no_content
      else
        render_bad_request(@booking)
      end
    end

    private

    def booking_params
      params.require(:booking).permit(:no_of_seats, :seat_price, :flight_id)
    end

    def admin_params
      params.require(:booking).permit(:no_of_seats, :seat_price, :flight_id, :user_id)
    end
  end
end
