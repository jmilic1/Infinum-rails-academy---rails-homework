class CompanySerializer < Blueprinter::Base
  identifier :id

  field :name, :created_at, :updated_at

  association :flights, blueprint: FlightSerializer
end
