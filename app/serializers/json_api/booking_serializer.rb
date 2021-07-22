module JsonApi
  class BookingSerializer
    include JSONAPI::Serializer

    attributes :no_of_seats, :seat_price

    belongs_to :user
    belongs_to :flight
  end
end
