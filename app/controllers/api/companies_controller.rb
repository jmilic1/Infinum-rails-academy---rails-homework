module Api
  class CompaniesController < ApplicationController
    def index
      common_index(CompanySerializer, Company, :companies)
    end

    def create
      @company = Company.new(company_params)
      authorize @company

      if @company.save
        render json: CompanySerializer.render(@company, view: :extended, root: :company),
               status: :created
      else
        render json: { errors: @company.errors }, status: :bad_request
      end

      #NEW
      common_create(CompanySerializer, Company, company_params, :company)
    end

    def show
      common_show(JsonApi::CompanySerializer, CompanySerializer, Company, :company)
    end

    # rubocop:disable Metrics/MethodLength
    def update
      @company = Company.find_by(id: params[:id])
      if @company.nil?
        return render json: { errors: 'Company with such id does not exist' }, status: :not_found
      end

      authorize @company

      if @company.update(company_params)
        render json: CompanySerializer.render(@company, view: :extended, root: :company),
               status: :ok
      else
        render json: { errors: @company.errors }, status: :bad_request
      end

      #NEW
      common_update(CompanySerializer, Company, company_params, :company)
    end
    # rubocop:enable Metrics/MethodLength

    def destroy
      @company = Company.find_by(id: params[:id])
      if @company.nil?
        return render json: { errors: 'Company with such id does not exist' }, status: :not_found
      end

      authorize @company

      if @company.destroy
        render json: {}, status: :no_content
      else
        render json: { errors: @company.errors }, status: :bad_request
      end

      #NEW
      common_destroy(Company)
    end

    private

    def company_params
      params.require(:company).permit(:name)
    end
  end
end
