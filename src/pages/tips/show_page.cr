class Tips::ShowPage < MainLayout
  needs tip : Tip

  def content
    h1 "Tip ##{tip.id}"

    para "Category: #{tip.category}"
    para "Description #{tip.description}"

    ul do
      li do
        link "Edit", to: Tips::Edit.with(tip.id)
      end
      li do
        link "Show", to: Tips::Show.with(tip.id)
      end
      li do
        link "Delete", to: Tips::Delete.with(tip.id)
      end
    end
  end
end
