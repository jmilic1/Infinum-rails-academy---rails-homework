module Api
  class CompaniesController < ApplicationController
    def index
      render json: { companies: Company.all }, status: :ok
    end

    def create
      company = Company.new(company_params)

      if company.save
        render json: { company: company }, status: :created
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def new
      render json: { company: Company.new }, status: :ok
    end

    def show
      get_company(params[:id])
    end

    def edit
      get_company(params[:id])
    end

    def update
      company = Company.find(params[:id])

      if company.nil?
        return render json: { errors: 'Company with such id does not exist' }, status: :bad_request
      end

      if company.update(company_params)
        render json: {}, status: :no_content
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def destroy
      company = Company.find(params[:id])

      if company.nil?
        return render json: { errors: 'Company with such id does not exist' }, status: :bad_request
      end

      if company.destroy
        render json: {}, status: :no_content
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    private

    def get_company(id)
      company = Company.find(id)

      if company.nil?
        render json: { errors: 'Company with such id does not exist' }, status: :bad_request
      else
        render json: { company: company }, status: :ok
      end
    end

    def company_params
      params.require(:company).permit(:name)
    end
  end
end
