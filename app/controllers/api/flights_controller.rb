module Api
  class FlightsController < ApplicationController
    before_action :authenticate_current_user, only: [:create, :update, :destroy]

    def index
      flights = active_flights(Flight.all)
      flights = custom_filter(flights)
      flights = sort_flights(flights)

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

    def active_flights(flights)
      flights.select do |flight|
        flight.departs_at > Time.zone.now
      end
    end

    def sort_flights(flights)
      flights.sort_by do |flight|
        [flight.departs_at,
         flight.name,
         flight.created_at]
      end
    end

    def apply_name_cont(flights, name_cont)
      flights.select { |flight| flight.name.downcase[name_cont.downcase] }
    end

    def apply_no_of_seats(flights, no_of_seats)
      flights.select { |flight| flight.no_of_seats >= no_of_seats.to_i }
    end

    def apply_departs_at_eq(flights, departs_at_eq)
      flights.select do |flight|
        flight.departs_at.to_i == Time.zone.parse(departs_at_eq).to_i
      end
    end

    def custom_filter(flights)
      name_cont = request.params['name_cont']
      no_of_seats = request.params['no_of_available_seats_gteq']
      departs_at_eq = request.params['departs_at_eq']

      flights = apply_name_cont(flights, name_cont) if name_cont
      flights = apply_no_of_seats(flights, no_of_seats) if no_of_seats
      flights = apply_departs_at_eq(flights, departs_at_eq) if departs_at_eq

      flights
    end
  end
end
