class SaveTip < Tip::SaveOperation
  permit_columns category, description
end
