FactoryBot.define do
  factory :booking do
    seat_price { 10 }
    no_of_seats { 10 }
    departs_at { Time.zone.now.getutc + 10000 }
  end
end
