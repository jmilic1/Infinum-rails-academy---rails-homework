class CompanySerializer < Blueprinter::Base
  identifier :id

  fields :name, :created_at, :updated_at

  view :extended do
    association :flights, blueprint: FlightSerializer
  end
end
