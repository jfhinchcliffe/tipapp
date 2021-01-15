class Tip::Create < BrowserAction
  post "/tips/create" do
    SaveTip.create(params, user_id: current_user.id) do |operation, tip|
      if tip
        flash.info = "Tip successfully added"
        redirect to: Tips::Index
      else
        flash.info = "Error saving Tip"
        html Tips::NewPage, operation: operation
      end
    end
  end
end
