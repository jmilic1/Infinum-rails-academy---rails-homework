module Api
  class CompaniesController < ApplicationController
    before_action :authenticate_current_user, only: [:create, :update, :destroy]

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
        render_bad_request(@company)
      end
    end

    def show
      @company = Company.find(params[:id])
      authorize @company

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { company: JsonApi::CompanySerializer.new(@company)
                                                          .serializable_hash.to_json },
               status: :ok
      else
        render json: CompanySerializer.render(@company, view: :extended, root: :company),
               status: :ok
      end
    end

    def update
      @company = Company.find(params[:id])
      authorize @company

      if @company.update(company_params)
        render json: CompanySerializer.render(@company, view: :extended, root: :company),
               status: :ok
      else
        render_bad_request(@company)
      end
    end

    def destroy
      @company = Company.find(params[:id])
      authorize @company

      if @company.destroy
        head :no_content
      else
        render_bad_request(@company)
      end
    end

    private

    def company_params
      params.require(:company).permit(:name)
    end
  end
end
