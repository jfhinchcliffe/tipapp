class Tip < BaseModel
  table do
    column category : String
    column description : String
    belongs_to user : User
  end
end
