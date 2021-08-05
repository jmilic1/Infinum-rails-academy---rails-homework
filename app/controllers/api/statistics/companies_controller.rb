module Api
  module Statistics
    class CompaniesController < ApplicationController
      before_action :authenticate_current_user, only: [:index]

      def index
        @companies = authorize [:statistics, Company.all]

        render json: CompanySerializer.render(@companies[1], root: :companies),
               status: :ok
      end
    end
  end
end
