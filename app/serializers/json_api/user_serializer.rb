module JsonApi
  class UserSerializer
    include JSONAPI::Serializer

    attributes :first_name, :last_name, :email, :role

    has_many :bookings
  end
end
