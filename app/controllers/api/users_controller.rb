module Api
  class UsersController < ApplicationController
    def index
      render json: { user: User.all }, status: :ok
    end

    def create
      user = User.new(user_params)

      if user.save
        render json: { user: user }, status: :created
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def new
      render json: { user: User.new }, status: :ok
    end

    def show
      get_user(params[:id])
    end

    def edit
      get_user(params[:id])
    end

    def update
      user = User.find(params[:id])

      if user.nil?
        return render json: { errors: 'User with such id does not exist' }, status: :bad_request
      end

      if user.update(user_params)
        render json: {}, status: :no_content
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def destroy
      user = User.find(params[:id])

      if user.nil?
        return render json: { errors: 'User with such id does not exist' }, status: :bad_request
      end

      if user.destroy
        render json: {}, status: :no_content
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    private

    def get_user(id)
      user = User.find(id)

      if user.nil?
        render json: { errors: 'User with such id does not exist' }, status: :bad_request
      else
        render json: { user: user }, status: :ok
      end
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email)
    end
  end
end
