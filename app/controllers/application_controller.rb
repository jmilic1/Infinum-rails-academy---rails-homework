class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound, with: :entity_not_found

  def render_bad_request(record)
    render json: { errors: record.errors }, status: :bad_request
  end

  def common_index(entity_serializer, entity, root)
    if request.headers['X_API_SERIALIZER_ROOT'] == '0'
      render json: entity_serializer.render(entity.all, view: :extended),
             status: :ok
    else
      render json: entity_serializer.render(entity.all, view: :extended, root: root),
             status: :ok
    end
  end

  def common_create(entity_serializer, entity, record_params, root)
    record = entity.new(record_params)

    if record.save
      render json: entity_serializer.render(record, view: :extended, root: root),
             status: :created
    else
      render_bad_request(record)
    end
  end

  def common_show(jsonapi_serializer, blprinter_serializer, entity, root)
    record = entity.find(params[:id])

    if request.headers['X_API_SERIALIZER'] == 'json_api'
      render json: { root => jsonapi_serializer.new(record).serializable_hash.to_json },
             status: :ok
    else
      render json: blprinter_serializer.render(record, view: :extended, root: root), status: :ok
    end
  end

  def common_update(entity_serializer, entity, record_params, root)
    record = entity.find(params[:id])

    if record.update(record_params)
      render json: entity_serializer.render(record, view: :extended, root: root), status: :ok
    else
      render_bad_request(record)
    end
  end

  def common_destroy(entity)
    record = entity.find(params[:id])

    if record.destroy
      render json: {}, status: :no_content
    else
      render_bad_request(record)
    end
  end

  private

  def entity_not_found
    controller = params['controller']
    render json: { errors: "#{controller[4..-2]} with such id does not exist" }, status: :not_found
  end
end
