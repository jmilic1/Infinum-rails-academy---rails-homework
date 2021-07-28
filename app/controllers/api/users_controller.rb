module Api
  class UsersController < ApplicationController
    def index
      @users = User.all
      authorize @users
      @users = policy_scope(User)

      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: UserSerializer.render(@users, view: :extended), status: :ok
      else
        render json: UserSerializer.render(@users, view: :extended, root: :users), status: :ok
      end
    end

    def create
      password = user_params['password']

      if password.nil? || password.length.zero?
        return render json: { errors: { credentials: ['are invalid'] } }, status: :bad_request
      end

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
      @users = policy_scope(User)

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { user: JsonApi::UserSerializer.new(@user).serializable_hash.to_json },
               status: :ok
      else
        render json: UserSerializer.render(@user, view: :extended, root: :user), status: :ok
      end
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def update
      @user = User.find(params[:id])
      authorize @user
      @user = policy_scope(User)

      user_values = user_params
      if !user_values['password'].nil? && user_values['password'].length.zero?
        return render json: { errors: { credentials: ['are invalid'] } },
                      status: :bad_request
      end

      if @user.update(user_values)
        render json: UserSerializer.render(@user, view: :extended, root: :user), status: :ok
      else
        render_bad_request(@user)
      end
    end
    # rubocop:enable Metrics/AbcSize

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
  end
end
