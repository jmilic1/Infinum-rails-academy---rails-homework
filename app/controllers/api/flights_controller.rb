module Api
  class FlightsController < ApplicationController
    def index
      common_index(FlightSerializer, Flight, :flights)
    end

    def create
      @flight = Flight.new(flight_params)
      authorize @flight

      if @flight.save
        render json: FlightSerializer.render(@flight, view: :extended, root: :flight),
               status: :created
      else
        render json: { errors: @flight.errors }, status: :bad_request
      end

      #NEW
      common_create(FlightSerializer, Flight, flight_params, :flight)
    end

    def show
      common_show(JsonApi::FlightSerializer, FlightSerializer, Flight, :flight)
    end

    def update
      @flight = Flight.find_by(id: params[:id])
      if @flight.nil?
        return render json: { errors: 'Flight with such id does not exist' }, status: :not_found
      end

      authorize @flight

      if @flight.update(flight_params)
        render json: FlightSerializer.render(@flight, view: :extended, root: :flight), status: :ok
      else
        render json: { errors: @flight.errors }, status: :bad_request
      end

      #NEW
      common_update(FlightSerializer, Flight, flight_params, :flight)
    end

    def destroy
      @flight = Flight.find_by(id: params[:id])
      if @flight.nil?
        return render json: { errors: 'Flight with such id does not exist' }, status: :not_found
      end

      authorize @flight

      if @flight.destroy
        render json: {}, status: :no_content
      else
        render json: { errors: @flight.errors }, status: :bad_request
      end

      #NEW
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
