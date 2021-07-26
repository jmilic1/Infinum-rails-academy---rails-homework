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

      #NEW
      common_index(UserSerializer, User, :users)
    end

    def create
      user_values = user_params

      if user_values['password'].nil? || user_values['password'].length.zero?
        return render json: { errors: { credentials: ['are invalid'] } }, status: :bad_request
      end

      user = User.new(user_params)

      if user.save
        render json: UserSerializer.render(user, view: :extended, root: :user), status: :created
      else
        render json: { errors: user.errors }, status: :bad_request
      end

      #NEW
      common_create(UserSerializer, User, user_params, :user)
    end

    # rubocop:disable Metrics/MethodLength
    def show
      @user = User.find_by(id: params[:id])
      if @user.nil?
        return render json: { errors: 'User with such id does not exist' }, status: :not_found
      end

      authorize @user
      @users = policy_scope(User)

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { user:  JsonApi::UserSerializer.new(@user).serializable_hash.to_json },
               status: :ok
      else
        render json: UserSerializer.render(@user, view: :extended, root: :user), status: :ok
      end

      #NEW
      common_show(JsonApi::UserSerializer, UserSerializer, User, :user)
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def update
      @user = User.find_by(id: params[:id])
      if @user.nil?
        return render json: { errors: 'User with such id does not exist' }, status: :not_found
      end

      authorize @user
      @users = policy_scope(User)

      user_values = user_params
      if !user_values['password'].nil? && user_values['password'].length.zero?
        return render json: { errors: { credentials: ['are invalid'] } },
                      status: :bad_request
      end

      if @user.update(user_values)
        render json: UserSerializer.render(@user, view: :extended, root: :user), status: :ok
      else
        render json: { errors: @user.errors }, status: :bad_request
      end

      #NEW
      common_update(UserSerializer, User, user_params, :user)
    end
    # rubocop:enable Metrics/AbcSize

    def destroy
      @user = User.find_by(id: params[:id])
      if @user.nil?
        return render json: { errors: 'User with such id does not exist' }, status: :not_found
      end

      authorize @user
      @users = policy_scope(User)

      if @user.destroy
        render json: {}, status: :no_content
      else
        render json: { errors: @user.errors }, status: :bad_request
      end

      #NEW
      common_destroy(User)
    end
    # rubocop:enable Metrics/MethodLength

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end
  end
end
