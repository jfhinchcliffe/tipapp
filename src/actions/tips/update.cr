class Tips::Update < BrowserAction
  put "/tips/:tipid" do
    tip = TipQuery.new.user_id(current_user.id).find(tipid)

    SaveTip.update(tip, params) do |form, item|
      if form.saved?
        flash.success = "Tip with id #{tipid} updated"
        redirect to: Tips::Index
      else
        flash.info = "Tip with id #{tipid} could not be saved"
        html Tips::EditPage, operation: form, tip: item
      end
    end
  end
end
