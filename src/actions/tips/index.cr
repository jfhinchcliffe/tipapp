class Tips::Index < BrowserAction
  get "/tips" do
    html Tips::IndexPage, tips: UserQuery.new.preload_tips.find(current_user.id).tips
  end
end
