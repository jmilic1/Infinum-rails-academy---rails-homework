module Api
  class FlightsController < ApplicationController
    before_action :authenticate_current_user, only: [:create, :update, :destroy]

    def index
      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: FlightSerializer.render(Flight.all, view: :extended),
               status: :ok
      else
        render json: FlightSerializer.render(Flight.all, view: :extended, root: :flights),
               status: :ok
      end
    end

    def create
      @flight = Flight.new(flight_params)
      authorize @flight

      if @flight.save
        render json: FlightSerializer.render(@flight, view: :extended, root: :flight),
               status: :created
      else
        render_bad_request(@flight)
      end
    end

    def show
      flight = Flight.find(params[:id])

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { flight: JsonApi::FlightSerializer.new(flight).serializable_hash.to_json },
               status: :ok
      else
        render json: FlightSerializer.render(flight, view: :extended, root: :flight), status: :ok
      end
    end

    def update
      @flight = Flight.find(params[:id])
      authorize @flight

      if @flight.update(flight_params)
        render json: FlightSerializer.render(@flight, view: :extended, root: :flight), status: :ok
      else
        render_bad_request(@flight)
      end
    end

    def destroy
      @flight = Flight.find(params[:id])
      authorize @flight

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
  end
end
