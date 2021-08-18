module Api
  module Statistics
    class CompaniesController < ApplicationController
      before_action :authenticate_current_user, only: [:index]

      def index
        @companies = authorize([:statistics, Company.all])[1]

        render json: ::Statistics::CompanySerializer.render(@companies, root: :companies),
               status: :ok
      end
    end
  end
end
