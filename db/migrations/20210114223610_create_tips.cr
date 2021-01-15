class CreateTips::V20210114223610 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(Tip) do
      primary_key id : Int64
      add_timestamps
      add category : String
      add description : String
      add user_id : Int64
    end
  end

  def rollback
    drop table_for(Tip)
  end
end
