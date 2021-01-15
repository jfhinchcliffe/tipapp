class Tips::Delete < BrowserAction
  delete "/tips/:tipid" do
    tip = TipQuery.new.user_id(current_user.id).find(tipid)

    if tip
      tip.delete
      flash.info = "Tip with id #{tipid} deleted"
    else
      flash.info = "Tip with id #{tipid} not found"
    end

    redirect to: Tips::Index
  end
end
