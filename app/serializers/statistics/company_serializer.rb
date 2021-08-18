module Statistics
  class CompanySerializer < Blueprinter::Base
    identifier :id, name: :company_id

    field :total_revenue, &:total_revenue

    field :total_no_of_booked_seats, &:total_no_of_booked_seats

    field :average_price_of_seats do |company|
      seats = company.total_no_of_booked_seats
      revenue = company.total_revenue.to_f
      if seats.zero?
        revenue
      else
        revenue / seats
      end
    end
  end
end
