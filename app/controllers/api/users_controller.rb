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
      common_update(UserSerializer, User, user_params, :user)
    end

    def destroy
      common_destroy(User)
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email)
    end
  end
end
