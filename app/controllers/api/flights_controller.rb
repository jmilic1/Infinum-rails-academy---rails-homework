module Api
  class FlightsController < ApplicationController
    def index
      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: FlightSerializer.render(Flight.all, view: :extended), status: :ok
      else
        render json: FlightSerializer.render(Flight.all, view: :extended, root: :flights),
               status: :ok
      end
    end

    def create
      flight = Flight.new(flight_params)

      if flight.save
        render json: FlightSerializer.render(flight, view: :extended, root: :flight),
               status: :created
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    def show
      flight = Flight.find(params[:id])

      if flight.nil?
        return render json: { errors: 'Flight with such id does not exist' }, status: :not_found
      end

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { flight: JsonApi::FlightSerializer.new(flight).serializable_hash.to_json },
               status: :ok
      else
        render json: FlightSerializer.render(flight, view: :extended, root: :flight), status: :ok
      end
    end

    def update
      flight = Flight.find(params[:id])

      if flight.nil?
        return render json: { errors: 'Flight with such id does not exist' }, status: :not_found
      end

      if flight.update(flight_params)
        render json: FlightSerializer.render(flight, view: :extended, root: :flight), status: :ok
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    def destroy
      flight = Flight.find(params[:id])

      if flight.nil?
        return render json: { errors: 'Flight with such id does not exist' }, status: :not_found
      end

      if flight.destroy
        render json: {}, status: :no_content
      else
        render json: { errors: flight.errors }, status: :bad_request
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
