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
      common_update(CompanySerializer, Company, company_params, :company)
    end

    def destroy
      common_destroy(Company)
    end

    private

    def company_params
      params.require(:company).permit(:name)
    end
  end
end
