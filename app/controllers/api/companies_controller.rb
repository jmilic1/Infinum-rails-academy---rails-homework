module Api
  class CompaniesController < ApplicationController
    def index
      common_index(CompanySerializer, Company, :companies)
    end

    def create
      common_create(CompanySerializer, Company, company_params, :company)
    end

    def show
      common_show(JsonApi::CompanySerializer, CompanySerializer, Company, :company)
    end

    def update
      company = Company.find(params[:id])

      if company.update(company_params)
        render json: CompanySerializer.render(company, view: :extended, root: :company), status: :ok
      else
        render_bad_request(company)
      end
    end

    def destroy
      company = Company.find(params[:id])

      if company.destroy
        render json: {}, status: :no_content
      else
        render_bad_request(company)
      end
    end

    private

    def company_params
      params.require(:company).permit(:name)
    end
  end
end
