class Tips::IndexPage < MainLayout
  needs tips : Array(Tip)

  def content
    h1 "Tips"
    link "New Tip", to: Tips::New
    table do
      tr do
        th "ID"
        th "Category"
        th "Description"
        th "Actions"
      end
      tips.each do |tip|
        tr do
          td tip.id
          td tip.category
          td tip.description
          td do
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
      end
    end
  end
end
