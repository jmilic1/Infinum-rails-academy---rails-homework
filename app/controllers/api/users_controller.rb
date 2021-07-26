module Api
  class UsersController < ApplicationController
    def index
      common_index(UserSerializer, User, :users)
    end

    def create
      common_create(UserSerializer, User, user_params, :user)
    end

    def show
      common_show(JsonApi::UserSerializer, UserSerializer, User, :user)
    end

    def update
      user = User.find(params[:id])

      if user.update(user_params)
        render json: UserSerializer.render(user, view: :extended, root: :user), status: :ok
      else
        render_bad_request(user)
      end
    end

    def destroy
      user = User.find(params[:id])

      if user.destroy
        render json: {}, status: :no_content
      else
        render_bad_request(user)
      end
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email)
    end
  end
end
