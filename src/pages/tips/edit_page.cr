class Tips::EditPage < MainLayout
  needs tip : Tip
  needs operation : SaveTip

  def content
    h1 "Edit Tip"

    form_for(Tips::Update.with(tip)) do
      label_for(@operation.category, "Category")
      text_input(@operation.category, attrs: [:required])
      label_for(@operation.description, "Description")
      text_input(@operation.description, attrs: [:required])
      submit "Update Tip"
    end
  end
end
