module Api
  class UsersController < ApplicationController
    # rubocop:disable Metrics/MethodLength
    def index
      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: UserSerializer.render_as_hash(User.all, view: :extended),
               status: :ok
      else
        render json: { users: UserSerializer.render_as_hash(User.all, view: :extended) },
               status: :ok
      end
    end

    def create
      user = User.new(user_params)

      if user.save
        render json: { user: UserSerializer.render_as_hash(user, view: :extended) },
               status: :created
      else
        render json: { errors: user.errors },
               status: :bad_request
      end
    end

    def show
      user = User.find(params[:id])

      if user.nil?
        return render json: { errors: 'User with such id does not exist' },
                      status: :bad_request
      end

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { user:  JsonApi::UserSerializer.new(user).serializable_hash.to_json },
               status: :ok
      else
        render json: { user: UserSerializer.render_as_hash(user, view: :extended) },
               status: :ok
      end
    end

    def update
      user = User.find(params[:id])

      if user.nil?
        return render json: { errors: 'User with such id does not exist' },
                      status: :bad_request
      end

      if user.update(user_params)
        render json: { user: UserSerializer.render_as_hash(user, view: :extended) },
               status: :ok
      else
        render json: { errors: user.errors },
               status: :bad_request
      end
    end

    def destroy
      user = User.find(params[:id])

      if user.nil?
        return render json: { errors: 'User with such id does not exist' },
                      status: :bad_request
      end

      if user.destroy
        render json: {},
               status: :no_content
      else
        render json: { errors: user.errors },
               status: :bad_request
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email)
    end
  end
end
