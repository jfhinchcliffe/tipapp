require "../spec/support/boxes/**"

# Add sample data helpful for development, e.g. (fake users, blog posts, etc.)
#
# Use `Db::CreateRequiredSeeds` if you need to create data *required* for your
# app to work.
class Db::CreateSampleSeeds < LuckyCli::Task
  summary "Add sample database records helpful for development"

  def call
    unless UserQuery.new.email("test-account@test.com").first?
      SaveUser.create!(
        email: "test-account@test.com",
        encrypted_password: Authentic.generate_encrypted_password("password")
      )
    end

    SaveTip.create!(
      user_id: UserQuery.new.email("test-account@test.com").first.id,
      category: "git",
      description: "`git log --oneline` will display a lost of recent commit subjects, without the body"
    )

    SaveTip.create!(
      user_id: UserQuery.new.email("test-account@test.com").first.id,
      category: "vscode",
      description: "`command + alt + arrow` will toggle between VS Code terminal windows"
    )
    puts "Done adding sample data"
  end
end
