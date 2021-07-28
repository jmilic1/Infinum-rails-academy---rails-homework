module Api
  class BookingsController < ApplicationController
    def index
      @bookings = Booking.all
      authorize @bookings
      @bookings = policy_scope(Booking)

      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: BookingSerializer.render(Booking.all, view: :extended),
               status: :ok
      else
        render json: BookingSerializer.render(Booking.all, view: :extended, root: :bookings),
               status: :ok
      end
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
        render_bad_request(booking)
      end
    end

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
    end

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
        render_bad_request(@booking)
      end
    end

    def destroy
      @booking = Booking.find_by(id: params[:id])
      if @booking.nil?
        return render json: { errors: { resource: ['is forbidden'] } }, status: :forbidden
      end

      authorize @booking
      @bookings = policy_scope(Booking)

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

    def find_user_by_token
      User.find_by(token: request.headers['Authorization'])
    end
  end
end
