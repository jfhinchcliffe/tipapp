class Tips::Show < BrowserAction
  get "/tips/:tipid" do
    html Tips::ShowPage, tip: TipQuery.new.user_id(current_user.id).find(tipid)
  end
end
