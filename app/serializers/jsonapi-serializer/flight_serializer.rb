class BookingSerializer
  include JSONAPI::Serializer

  attributes :name, :no_of_seats, :base_price, :departs_at, :arrives_at
  has_many :bookings
  belongs_to :company
end
