module JsonApi
  class CompanySerializer
    include JSONAPI::Serializer

    attributes :name

    has_many :flights
  end
end
