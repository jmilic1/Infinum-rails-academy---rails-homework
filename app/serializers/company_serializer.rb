class CompanySerializer < Blueprinter::Base
  identifier :id
  field :name
  association :flights
end
