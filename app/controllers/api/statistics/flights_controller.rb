module Api
  module Statistics
    class FlightsController < ApplicationController
      before_action :authenticate_current_user, only: [:index]

      def index
        authorize [:statistics, Flight]
        @flights = filter(policy_scope(Flight.all))

        render json: Statistics.FlightSerializer.render(@flights, root: :flights),
               status: :ok
      end
    end
  end
end
