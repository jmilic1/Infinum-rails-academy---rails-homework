module Api
  class FlightsController < ApplicationController
    def index
      render json: { flight: Flight.all }, status: :ok
    end

    def create
      flight = Flight.new(flight_params)

      if flight.save
        render json: { flight: flight }, status: :created
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    def new
      render json: { flight: Flight.new }, status: :ok
    end

    def show
      get_flight(params[:id])
    end

    def edit
      get_flight(params[:id])
    end

    def update
      flight = Flight.find(params[:id])

      if flight.nil?
        return render json: { errors: 'Flight with such id does not exist' }, status: :bad_request
      end

      if flight.update(flight_params)
        render json: {}, status: :no_content
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    def destroy
      flight = Flight.find(params[:id])

      if flight.nil?
        return render json: { errors: 'Flight with such id does not exist' }, status: :bad_request
      end

      if flight.destroy
        render json: {}, status: :no_content
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    private

    def get_flight(id)
      flight = Flight.find(id)

      if flight.nil?
        render json: { errors: 'Flight with such id does not exist' }, status: :bad_request
      else
        render json: { flight: flight }, status: :ok
      end
    end

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
