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
      common_update(FlightSerializer, Flight, flight_params, :flight)
    end

    def destroy
      common_destroy(Flight)
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
