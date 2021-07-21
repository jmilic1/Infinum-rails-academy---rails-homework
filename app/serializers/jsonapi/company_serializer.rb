class BookingSerializer
  include JSONAPI::Serializer

  attributes :name
  has_many :flights
end
