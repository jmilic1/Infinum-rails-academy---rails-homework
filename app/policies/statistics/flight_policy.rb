module Api
  module Statistics
    class FlightPolicy
      attr_reader :user, :record

      def initialize(user, record)
        @user = user
        @record = record
      end

      def index?
        user.admin?
      end
    end
  end
end