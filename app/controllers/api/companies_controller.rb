module Api
  class CompaniesController < ApplicationController
    def index
      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: CompanySerializer.render(Company.all, view: :extended),
               status: :ok
      else
        render json: CompanySerializer.render(Company.all, view: :extended, root: :companies),
               status: :ok
      end
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
    end

    def show
      company = Company.find_by(id: params[:id])
      if company.nil?
        return render json: { errors: 'Company with such id does not exist' }, status: :not_found
      end

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { company: JsonApi::CompanySerializer.new(company).serializable_hash.to_json },
               status: :ok
      else
        render json: CompanySerializer.render(company, view: :extended, root: :company), status: :ok
      end
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
    end

    private

    def company_params
      params.require(:company).permit(:name)
    end
  end
end
