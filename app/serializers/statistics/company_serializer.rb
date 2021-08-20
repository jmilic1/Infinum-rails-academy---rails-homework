module Statistics
  class CompanySerializer < Blueprinter::Base
    identifier :id, name: :company_id

    # rubocop:disable Style/SymbolProc
    field :total_revenue do |company|
      company.total_revenue
    end

    field :total_no_of_booked_seats do |company|
      company.total_no_of_booked_seats
    end
    # rubocop:enable Style/SymbolProc

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
