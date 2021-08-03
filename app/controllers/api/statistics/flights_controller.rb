module Api
  module Statistics
    class FlightsController < ApplicationController
      def index
        authorize Flight
        @flights = filter(policy_scope(Flight.all))

        render json: Statistics.FlightSerializer.render(@flights, view: :extended, root: :users),
               status: :ok
      end
    end
  end
end
