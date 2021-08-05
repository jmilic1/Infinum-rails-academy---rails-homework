module Api
  module Statistics
    class FlightsController < ApplicationController
      before_action :authenticate_current_user, only: [:index]

      def index
        @flights = authorize [:statistics, Flight.all]

        render json: FlightSerializer.render(@flights[1], root: :flights),
               status: :ok
      end
    end
  end
end
