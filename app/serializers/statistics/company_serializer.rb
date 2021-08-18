module Statistics
  class CompanySerializer < Blueprinter::Base
    identifier :id, name: :company_id

    field :total_revenue do |company|
      Company.total_revenue(company)
    end

    field :total_no_of_booked_seats do |company|
      Company.total_no_of_booked_seats(company)
    end

    field :average_price_of_seats do |company|
      seats = Company.total_no_of_booked_seats(company)
      revenue = Company.total_revenue(company).to_f
      if seats.zero?
        revenue
      else
        revenue / seats
      end
    end
  end
end
