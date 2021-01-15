class Tips::New < BrowserAction
  get "/tips/new" do
    html Tips::NewPage, operation: SaveTip.new
  end
end
