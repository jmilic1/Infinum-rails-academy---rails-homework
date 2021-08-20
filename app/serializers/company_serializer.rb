# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class CompanySerializer < Blueprinter::Base
  identifier :id

  fields :name, :created_at, :updated_at
  # rubocop:disable Style/SymbolProc
  field :no_of_active_flights do |company|
    company.no_of_active_flights
  end
  # rubocop:enable Style/SymbolProc

  view :extended do
    association :flights, blueprint: FlightSerializer
  end
end
