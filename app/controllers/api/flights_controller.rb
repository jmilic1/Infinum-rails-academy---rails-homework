module Api
  class FlightsController < ApplicationController
    # rubocop:disable Layout/LineLength
    def index
      if request.headers['x_api_serializer_root'] == '0'
        render json: FlightSerializer.render_as_hash(Flight.all, view: :extended), status: :ok
      else
        render json: { flights: FlightSerializer.render_as_hash(Flight.all, view: :extended) }, status: :ok
      end
    end

    def create
      flight = Flight.new(flight_params)

      if flight.save
        render json: { flight: FlightSerializer.render_as_hash(flight, view: :extended) }, status: :created
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end
    # rubocop:enable Layout/LineLength

    def show
      flight = Flight.find(params[:id])

      if flight.nil?
        return render json: { errors: 'Flight with such id does not exist' }, status: :bad_request
      end

      # rubocop:disable Layout/LineLength
      if request.headers['x_api_serializer'] == 'json_api'
        render json: { flight: JsonApi::FlightSerializer.new(flight).serializable_hash.to_json }, status: :ok
      else
        render json: { flight: FlightSerializer.render_as_hash(flight, view: :extended) }, status: :ok
      end
      # rubocop:enable Layout/LineLength
    end

    def update
      flight = Flight.find(params[:id])

      if flight.nil?
        return render json: { errors: 'Flight with such id does not exist' }, status: :bad_request
      end

      if flight.update(flight_params)
        # rubocop:disable Layout/LineLength
        render json: { flight: FlightSerializer.render_as_hash(flight, view: :extended) }, status: :ok
        # rubocop:enable Layout/LineLength
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
