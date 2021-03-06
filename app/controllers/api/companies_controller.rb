module Api
  class CompaniesController < ApplicationController
    before_action :authenticate_current_user, only: [:create, :update, :destroy]

    def index
      companies = filter_companies.order(:name).uniq

      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: CompanySerializer.render(companies, view: :extended),
               status: :ok
      else
        render json: CompanySerializer.render(companies, view: :extended, root: :companies),
               status: :ok
      end
    end

    def create
      @company = authorize Company.new(company_params)

      if @company.save
        render json: CompanySerializer.render(@company, view: :extended, root: :company),
               status: :created
      else
        render_bad_request(@company)
      end
    end

    def show
      @company = authorize Company.find(params[:id])

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
      @company = authorize Company.find(params[:id])

      if @company.update(company_params)
        render json: CompanySerializer.render(@company, view: :extended, root: :company),
               status: :ok
      else
        render_bad_request(@company)
      end
    end

    def destroy
      @company = authorize Company.find(params[:id])

      if @company.destroy
        head :no_content
      else
        render_bad_request(@company)
      end
    end

    private

    def filter_companies
      return Company.all if request.params['filter'] != 'active'

      Company.joins(:flights).where('departs_at > ?', Time.zone.now)
    end

    def company_params
      params.require(:company).permit(:name)
    end
  end
end
