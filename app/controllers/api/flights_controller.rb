module Api
  class FlightsController < ApplicationController
    before_action :authenticate_current_user, only: [:create, :update, :destroy]

    def index
      flights = filter_flights.order(:departs_at, :name, :created_at)

      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: FlightSerializer.render(flights, view: :extended),
               status: :ok
      else
        render json: FlightSerializer.render(flights, view: :extended, root: :flights),
               status: :ok
      end
    end

    def create
      @flight = authorize Flight.new(flight_params)

      if @flight.save
        render json: FlightSerializer.render(@flight, view: :extended, root: :flight),
               status: :created
      else
        render_bad_request(@flight)
      end
    end

    def show
      @flight = authorize Flight.find(params[:id])

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { flight: JsonApi::FlightSerializer.new(@flight).serializable_hash.to_json },
               status: :ok
      else
        render json: FlightSerializer.render(@flight, view: :extended, root: :flight), status: :ok
      end
    end

    def update
      @flight = authorize Flight.find(params[:id])

      if @flight.update(flight_params)
        render json: FlightSerializer.render(@flight, view: :extended, root: :flight), status: :ok
      else
        render_bad_request(@flight)
      end
    end

    def destroy
      @flight = authorize Flight.find(params[:id])

      if @flight.destroy
        head :no_content
      else
        render_bad_request(@flight)
      end
    end

    private

    def flight_params
      params.require(:flight).permit(:no_of_seats,
                                     :base_price,
                                     :name,
                                     :departs_at,
                                     :arrives_at,
                                     :name,
                                     :company_id)
    end

    # rubocop:disable Metrics/AbcSize
    def filter_flights
      flights = Flight.where('departs_at > ?', Time.zone.now)

      name_cont = request.params['name_cont']
      no_of_seats = request.params['no_of_available_seats_gteq']
      departs_at_eq = request.params['departs_at_eq']

      flights = flights.where('name ILIKE ?', "%#{name_cont.downcase}%") if name_cont
      flights = flights.where('no_of_seats >= ?', no_of_seats) if no_of_seats
      if departs_at_eq
        flights = flights.where('DATE(departs_at) = ?', Time.zone.parse(departs_at_eq))
      end
      flights
    end
    # rubocop:enable Metrics/AbcSize
  end
end
