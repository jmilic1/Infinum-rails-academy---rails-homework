module Api
  class UsersController < ApplicationController
    before_action :authenticate_current_user, only: [:index, :show, :update, :destroy]
    def index
      @users = User.all
      authorize @users
      @users = policy_scope(@users)

      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: UserSerializer.render(@users, view: :extended), status: :ok
      else
        render json: UserSerializer.render(@users, view: :extended, root: :users), status: :ok
      end
    end

    def create
      # password = user_params['password']
      #
      # # if password.nil? || password.length.zero?
      # #   return render json: { errors: [ email ] }, status: :bad_request
      # # end

      user = User.new(user_params)

      if user.save
        render json: UserSerializer.render(user, view: :extended, root: :user), status: :created
      else
        render_bad_request(user)
      end
    end

    def show
      @user = User.find(params[:id])
      authorize @user
      @user = policy_scope(@user)

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { user: JsonApi::UserSerializer.new(@user).serializable_hash.to_json },
               status: :ok
      else
        render json: UserSerializer.render(@user, view: :extended, root: :user), status: :ok
      end
    end

    # rubocop:disable Metrics/MethodLength
    def update
      @user = User.find(params[:id])
      authorize @user
      @user = policy_scope(@user)

      password = role_params[:password]
      if password.nil? || password.length.zero?
        return render json: { errors: { credentials: ['are invalid'] } },
                      status: :bad_request
      end

      if @user.update(role_params)
        render json: UserSerializer.render(@user, view: :extended, root: :user), status: :ok
      else
        render_bad_request(@user)
      end
    end

    def destroy
      @user = User.find(params[:id])
      authorize @user
      @users = policy_scope(User)

      if @user.destroy
        head :no_content
      else
        render_bad_request(@user)
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end

    def admin_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :role)
    end

    def role_params
      if current_user.admin?
        admin_params
      else
        user_params
      end
    end
  end
end
