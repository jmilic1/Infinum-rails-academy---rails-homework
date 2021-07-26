module Api
  class BookingsController < ApplicationController
    # rubocop:disable Metrics/MethodLength
    def index
      @bookings = Booking.all
      authorize @bookings
      @bookings = policy_scope(Booking)

      common_index(BookingSerializer, @bookings, :bookings)
    end

    def create
      user = find_user_by_token
      return render json: { errors: { token: ['is invalid'] } }, status: :unauthorized if user.nil?

      booking = Booking.new(booking_params)
      booking.user_id = user.id

      if booking.save
        render json: BookingSerializer.render(booking, view: :extended, root: :booking),
               status: :created
      else
        render json: { errors: booking.errors },
               status: :bad_request
      end

      ##NEW
      common_create(BookingSerializer, Booking, booking_params, :booking)
    end

    # rubocop:disable Layout/LineLength
    def show
      @booking = Booking.find_by(id: params[:id])
      if @booking.nil?
        return render json: { errors: 'Booking with such id does not exist' }, status: :not_found
      end

      authorize @booking
      @bookings = policy_scope(Booking)

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { booking: JsonApi::BookingSerializer.new(@booking).serializable_hash.to_json },
               status: :ok
      else
        render json: BookingSerializer.render(@booking, view: :extended, root: :booking),
               status: :ok
      end

      ##NEW
      common_show(JsonApi::BookingSerializer, BookingSerializer, Booking, :booking)
    end
    # rubocop:enable Layout/LineLength

    def update
      @booking = Booking.find_by(id: params[:id])
      if @booking.nil?
        return render json: { errors: { resource: ['is forbidden'] } }, status: :forbidden
      end

      authorize @booking
      @bookings = policy_scope(Booking)

      if @booking.update(booking_params)
        render json: BookingSerializer.render(@booking, view: :extended, root: :booking),
               status: :ok
      else
        render json: { errors: @booking.errors }, status: :bad_request
      end

      ##NEW
      common_update(BookingSerializer, Booking, booking_params, :booking)
    end

    def destroy
      @booking = Booking.find_by(id: params[:id])
      if @booking.nil?
        return render json: { errors: { resource: ['is forbidden'] } }, status: :forbidden
      end

      authorize @booking
      @bookings = policy_scope(Booking)

      if @booking.destroy
        render json: {}, status: :no_content
      else
        render json: { errors: @booking.errors }, status: :bad_request
      end

      ##NEW
      common_destroy(Booking)
    end

    private

    def booking_params
      params.require(:booking).permit(:no_of_seats, :seat_price, :flight_id)
    end

    def find_user_by_token
      User.find_by(token: request.headers['Authorization'])
    end
    # rubocop:enable Metrics/MethodLength
  end
end
