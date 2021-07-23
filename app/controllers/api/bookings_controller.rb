module Api
  class BookingsController < ApplicationController
    def index
      user = find_user_by_token
      if user.nil?
        return render json: { errors: 'No user with such token exists' }, status: :bad_request
      end

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
      booking = Booking.new(booking_params)

      if booking.save
        render json: BookingSerializer.render(booking, view: :extended, root: :booking),
               status: :created
      else
        render json: { errors: booking.errors },
               status: :bad_request
      end
    end

    def show
      booking = Booking.find_by(id: params[:id])
      if booking.nil?
        return render json: { errors: 'Booking with such id does not exist' }, status: :not_found
      end

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { booking: JsonApi::BookingSerializer.new(booking).serializable_hash.to_json },
               status: :ok
      else
        render json: BookingSerializer.render(booking, view: :extended, root: :booking), status: :ok
      end
    end

    def update
      booking = Booking.find_by(id: params[:id])
      if booking.nil?
        return render json: { errors: 'Booking with such id does not exist' }, status: :not_found
      end

      if booking.update(booking_params)
        render json: BookingSerializer.render(booking, view: :extended, root: :booking), status: :ok
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def destroy
      booking = Booking.find_by(id: params[:id])
      if booking.nil?
        return render json: { errors: 'Booking with such id does not exist' }, status: :not_found
      end

      if booking.destroy
        render json: {}, status: :no_content
      else
        render json: { errors: errors }, status: :bad_request
      end
    end

    private

    def booking_params
      params.require(:booking).permit(:no_of_seats, :seat_price, :flight_id, :user_id)
    end

    def find_user_by_token
      User.find_by(token: request.headers['Authorization'])
    end
  end
end
