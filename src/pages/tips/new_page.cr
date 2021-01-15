class Tips::NewPage < MainLayout
  needs operation : SaveTip

  def content
    h1 "Create New Tip"

    form_for(Tip::Create) do
      label_for(operation.category, "Category")
      text_input(operation.category, attrs: [:required])
      label_for(operation.description, "Description")
      text_input(operation.description, attrs: [:required])
      submit "Create Tip"
    end
  end
end
