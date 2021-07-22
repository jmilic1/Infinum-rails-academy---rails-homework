module Api
  class CompaniesController < ApplicationController
    def index
      render json: { companies: CompanySerializer.render_as_hash(Company.all) }, status: :ok
    end

    def create
      company = Company.new(company_params)

      if company.save
        render json: { company: CompanySerializer.render(company) }, status: :created
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def show
      company = Company.find(params[:id])

      if company.nil?
        return render json: { errors: 'Company with such id does not exist' }, status: :bad_request
      end

      # rubocop:disable Layout/LineLength
      if request.headers['x_api_serializer'] == 'json_api'
        render json: { company: JsonApi::CompanySerializer.new(company).serializable_hash.to_json }, status: :ok
      else
        render json: { company: CompanySerializer.render(company) }, status: :ok
      end
      # rubocop:enable Layout/LineLength
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

    def company_params
      params.require(:company).permit(:name)
    end
  end
end
