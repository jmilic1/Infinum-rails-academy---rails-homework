module Api
  class BookingsController < ApplicationController
    before_action :authenticate_current_user, only: [:index, :create, :show, :update, :destroy]

    # rubocop:disable Metrics
    def index
      # authorize Booking.includes(:flight, :user)
      @bookings = policy_scope(Booking.includes(:flight, :user, flight: [:company])
                                      .order('flight.departs_at, flight.name, flight.created_at'))
      authorize @bookings

      @bookings = active_bookings(@bookings) if request.params['filter'] == 'active'
      # @bookings = sort_bookings(@bookings)

      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: BookingSerializer.render(@bookings.includes(:flight,
                                                                 :user,
                                                                 flight: [:company]),
                                              view: :extended), status: :ok
      else
        render json: BookingSerializer.render(@bookings.includes(:flight,
                                                                 :user,
                                                                 flight: [:company]),
                                              view: :extended, root: :bookings),
               status: :ok
      end
    end
    # rubocop:enable Metrics

    def create
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
      @booking = Booking.find(params[:id])
      authorize @booking

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

    def active_bookings(bookings)
      bookings.select do |booking|
        booking.flight.departs_at > DateTime.now
      end
    end

    # def sort_bookings(bookings)
    #   bookings.includes(:flight).sort_by do |booking|
    #     [booking.flight.departs_at,
    #      booking.flight.name,
    #      booking.created_at]
    #   end
    # end
  end
end
