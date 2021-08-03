module Api
  module Statistics
    class CompaniesController < ApplicationController
      before_action :authenticate_current_user, only: [:index]

      def index
        authorize Company
        @companies = filter(policy_scope(Company.all))

        render json: Statistics.CompanySerializer.render(@companies, root: :companies),
               status: :ok
      end
    end
  end
end
