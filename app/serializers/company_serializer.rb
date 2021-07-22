class CompanySerializer < Blueprinter::Base
  identifier :id

  fields :name, :created_at, :updated_at

  association :flights, blueprint: FlightSerializer
end
