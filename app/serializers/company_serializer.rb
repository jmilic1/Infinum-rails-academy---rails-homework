class UserSerializer < Blueprinter::Base
  identifier :id
  field :name
  association :flights
end
