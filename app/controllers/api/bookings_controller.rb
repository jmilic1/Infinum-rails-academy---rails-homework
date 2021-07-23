module Api
  class BookingsController < ApplicationController
    def index
      user = find_user_by_token
      return render json: { errors: { token: ['is invalid'] } }, status: :bad_request if user.nil?

      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: BookingSerializer.render(Booking.find_by(user_id: user.id), view: :extended),
               status: :ok
      else
        render json: BookingSerializer.render(Booking.find_by(user_id: user.id), view: :extended,
                                                                                 root: :bookings),
               status: :ok
      end
    end

    def create
      user = find_user_by_token
      return render json: { errors: { token: ['is invalid'] } }, status: :bad_request if user.nil?

      booking = Booking.new(booking_params)
      booking.user_id = user.id

      if booking.save
        render json: BookingSerializer.render(booking, view: :extended, root: :booking),
               status: :created
      else
        render json: { errors: booking.errors },
               status: :bad_request
      end
    end

    def show
      user = find_user_by_token
      return render json: { errors: { token: ['is invalid'] } }, status: :bad_request if user.nil?

      booking = Booking.find_by(id: params[:id], user_id: user.id)
      if booking.nil?
        return render json: { errors: 'Booking with such id was not found' }, status: :not_found
      end

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { booking: JsonApi::BookingSerializer.new(booking).serializable_hash.to_json },
               status: :ok
      else
        render json: BookingSerializer.render(booking, view: :extended, root: :booking), status: :ok
      end
    end

    def update
      user = find_user_by_token
      return render json: { errors: { token: ['is invalid'] } }, status: :bad_request if user.nil?

      booking = Booking.find_by(id: params[:id], user_id: user.id)
      if booking.nil?
        return render json: { errors: 'Booking with such id was not found' }, status: :not_found
      end

      if booking.update(booking_params)
        render json: BookingSerializer.render(booking, view: :extended, root: :booking), status: :ok
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def destroy
      user = find_user_by_token
      return render json: { errors: { token: ['is invalid'] } }, status: :bad_request if user.nil?

      booking = Booking.find_by(id: params[:id], user_id: user.id)
      if booking.nil?
        return render json: { errors: 'Booking with such id was not found' }, status: :not_found
      end

      if booking.destroy
        render json: {}, status: :no_content
      else
        render json: { errors: errors }, status: :bad_request
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
