module Api
  module Statistics
    class FlightsController < ApplicationController
      before_action :authenticate_current_user, only: [:index]

      def index
        @flights = authorize([:statistics, Flight.all])[1]

        render json: ::Statistics::FlightSerializer.render(@flights, root: :flights),
               status: :ok
      end
    end
  end
end
