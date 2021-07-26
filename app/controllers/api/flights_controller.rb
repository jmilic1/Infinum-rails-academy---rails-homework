module Api
  class FlightsController < ApplicationController
    def index
      common_index(FlightSerializer, Flight, :flights)
    end

    def create
      common_create(FlightSerializer, Flight, flight_params, :flight)
    end

    def show
      common_show(JsonApi::FlightSerializer, FlightSerializer, Flight, :flight)
    end

    def update
      flight = Flight.find(params[:id])

      if flight.update(flight_params)
        render json: FlightSerializer.render(flight, view: :extended, root: :flight), status: :ok
      else
        render_bad_request(flight)
      end
    end

    def destroy
      flight = Flight.find(params[:id])

      if flight.destroy
        render json: {}, status: :no_content
      else
        render_bad_request(flight)
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
  end
end
