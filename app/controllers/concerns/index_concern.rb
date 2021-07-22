module IndexConcern
  extend ActiveSupport::Concern

  included do
    helper_method :render_index
  end

  def render_index(x_api_serializer_root, no_root, root)
    if x_api_serializer_root == '0'
      render no_root
    else
      render root
    end
  end
end
