class Tips::Edit < BrowserAction
  get "/tips/:tipid/edit" do
    tip = TipQuery.new.user_id(current_user.id).find(tipid)

    if tip
      html Tips::EditPage, tip: tip, operation: SaveTip.new(tip)
    else
      flash.info = "Tip with id #{tipid} not found"
      redirect to: Tips::Index
    end
  end
end
