module Api
  class UsersController < ApplicationController
    before_action :authenticate_current_user, only: [:index, :show, :update, :destroy]

    def index
      @users = policy_scope(authorize(User.all)).sort_by(&:email)
      @users = filter(@users)

      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: UserSerializer.render(@users, view: :extended), status: :ok
      else
        render json: UserSerializer.render(@users, view: :extended, root: :users), status: :ok
      end
    end

    def create
      user = User.new(user_params)

      if user.save
        render json: UserSerializer.render(user, view: :extended, root: :user), status: :created
      else
        render_bad_request(user)
      end
    end

    def show
      @user = policy_scope(authorize(User.find(params[:id])))

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { user: JsonApi::UserSerializer.new(@user).serializable_hash.to_json },
               status: :ok
      else
        render json: UserSerializer.render(@user, view: :extended, root: :user), status: :ok
      end
    end

    def update
      @user = policy_scope(authorize(User.find(params[:id])))

      if @user.update(user_params)
        render json: UserSerializer.render(@user, view: :extended, root: :user), status: :ok
      else
        render_bad_request(@user)
      end
    end

    def destroy
      @user = policy_scope(authorize(User.find(params[:id])))

      if @user.destroy
        head :no_content
      else
        render_bad_request(@user)
      end
    end

    private

    def user_params
      if !current_user.nil? && current_user.admin?
        params.require(:user).permit(:first_name, :last_name, :email, :password, :role)
      else
        params.require(:user).permit(:first_name, :last_name, :email, :password)
      end
    end

    # rubocop:disable Metrics/AbcSize
    def filter(users)
      query = request.params['query']
      return users if query.nil?

      users.select do |user|
        user.first_name.downcase.include?(query.downcase) ||
          (!user.last_name.nil? && user.last_name.downcase.include?(query.downcase)) ||
          user.email.downcase.include?(query.downcase)
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
