module Api
  class FlightsController < ApplicationController
    # rubocop:disable Metrics/MethodLength
    def index
      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: FlightSerializer.render_as_hash(Flight.all, view: :extended),
               status: :ok
      else
        render json: { flights: FlightSerializer.render_as_hash(Flight.all, view: :extended) },
               status: :ok
      end
    end

    def create
      flight = Flight.new(flight_params)

      if flight.save
        render json: { flight: FlightSerializer.render_as_hash(flight, view: :extended) },
               status: :created
      else
        render json: { errors: flight.errors },
               status: :bad_request
      end
    end

    def show
      flight = Flight.find(params[:id])

      if flight.nil?
        return render json: { errors: 'Flight with such id does not exist' },
                      status: :bad_request
      end

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { flight: JsonApi::FlightSerializer.new(flight).serializable_hash.to_json },
               status: :ok
      else
        render json: { flight: FlightSerializer.render_as_hash(flight, view: :extended) },
               status: :ok
      end
    end

    def update
      flight = Flight.find(params[:id])

      if flight.nil?
        return render json: { errors: 'Flight with such id does not exist' },
                      status: :bad_request
      end

      if flight.update(flight_params)
        render json: { flight: FlightSerializer.render_as_hash(flight, view: :extended) },
               status: :ok
      else
        render json: { errors: flight.errors },
               status: :bad_request
      end
    end

    def destroy
      flight = Flight.find(params[:id])

      if flight.nil?
        return render json: { errors: 'Flight with such id does not exist' },
                      status: :bad_request
      end

      if flight.destroy
        render json: {},
               status: :no_content
      else
        render json: { errors: flight.errors },
               status: :bad_request
      end
    end
    # rubocop:enable Metrics/MethodLength

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
