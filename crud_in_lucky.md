# How to set up CRUD in Lucky

I primarily use Rails in my work, and Rails, like Ludo from The Labyrinth, is a large and _very_ helpful beast. Did you want to create a model and some CRUD routes to it at the same time? Type in `rails g scaffold Post title content`, run a migration and you're golden.

On Lucky, it's not quite so straightforward. Creating CRUD routes for a resource touches quite a few aspects of the framework which are covered separately in the docs - actions, pages, routes, and forms and so on. As there aren't a squillion tutorials online (like Rails) I found it a bit hard to grasp so I'm putting it all in a single guide to try and show how everything hangs together.

As an added bonus, I'm using the default User model provided with Lucky so that we can associate the resource we're CRUDding with the current user. Truly living on the ragged edge of humanity's techonological capabilities!

This guide won't get super into the nitty gritty of Crystal or Lucky. Rather it's a way to draw parallels between Rails and Lucky through a commonly built feature (CRUD for a resource) in a way that would have helped _me_ as I learn Lucky coming from Rails.

The repo for this project can be found [here](github link).

## What The CRUD?
[CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) stands for Create, Read, Update and Delete. These are common actions that you may want to perform on a resource in an application.

## What are we doing to do?
We're going to create a Lucky app which saves coding tips which I'll define in a model called `Tips`.
At work I pair a lot and I often see a colleague do something cool with their editor that I have no idea how to do. I ask them how to do it, they tell me, I nod, and the information promptly falls out of my ears. With this app, I'll never forget a handy tip again!

## Before we start...
Make sure you have Crystal and Lucky installed. Guide can be found [here](https://www.luckyframework.org/guides/getting-started/installing)

When you go to a terminal, typing `lucky -v` and `crystal -v` should return the version of Lucky and Crystal you have installed respectively.

### Note
I've got my `psql` database running in Docker on port 5432. See the [docker-compose.yml](TODO Docker compose file link) file on the example repo if you don't want to install Postgres locally. If you _do_ have Postgres running locally... well you just don't need to do this!

## Step 1 - Create a new Lucky app
Related Documentation - [Starting a Lucky Project](https://www.luckyframework.org/guides/getting-started/starting-project)

In your terminal, type `lucky init` and you'll be taken through the setup of a new Lucky app.
- Enter the name of your project - I'm calling it `tipapp`
- Choose whether you'd like it to be a 'full' app, or 'API Only' - Select `full`
- Choose whether you'd like authentication generated for you - Select `y`

The app should be generated for you.

- Run `cd tipapp` to navigate into your shiny new Lucky app.
- Run `script/setup` to install all JS dependencies, Crystal shards, setup the DB and perform various other little machinations for your new project (warning: this may take a little while)
- After setup is complete, run `lucky dev` and wait while your app shakes the dust from its shoulders and shambles on over to `http://localhost:3001`.

## Step 2 - Create a User
Now if you poke around in the code, you can see that Lucky has kindly generated a User model for us at `tipapp/src/models/user.cr` which has an email and an authenticated_password property. It has also already created this table in the Database as part of `script/setup`.

Just so we have a User to work with, head to the `http://localhost:3001/sign_up` page and create an account. If you're successful, you'll be taken to this handsome profile page at `http://localhost:3001/me`

## INSERT DEFAULT PROFILE PAGE PIC

## Step 3 - Create the Tip Resource
Related Documentation - [Database Models](https://www.luckyframework.org/guides/database/models), [Migrating Data](https://www.luckyframework.org/guides/database/migrations)

We need something to CRUD, so let's add the Tip resource.
Much like Rails, we get a generator which we can use to create a resource. Our Tip model will have the following properties:
- `category` - eg Bash, SQL, Ruby
- `description` - a detailed writeup of the tip
- `user_id` - the ID of the User who created this Tip

We can generate the model and a few other required files (query, migration etc.) with the following command:

`lucky gen.model Tip category:String description:String user_id:Int64`

Review your migration file (eg `tipapp/db/migrations/20210114223610_create_tips.cr`) to confirm the fields are correct, and then to put the new model in the database, run:

`lucky db.migrate`

All things going well, you'll now have a Tips table in your database.

To create the [association](https://www.luckyframework.org/guides/database/models#model-associations) between the User and the Tip, add the following relationship to your `tipapp/src/models/user.cr` file within the table block:
```crystal
has_many tips : Tip
```
and within your Tip file, within the table block:
```crystal
belongs_to user : User
```

## Step 4 - Seed Some Data!

We want to seed User and Tip information to the database, so first, create a `SaveUser` operation in `tipapp/src/operations/save_user.cr`, with the following content:

```crystal
class SaveUser < User::SaveOperation
end
```
This will allow us to save a User from our seed file.

Replace the `call` method in your `tipapp/tasks/create_sample_seeds.cr` file with:

```crystal
  # tipapp/tasks/create_sample_seeds.cr
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
```
and run `lucky db.create_sample_seeds`

Congratulations! That was a big step, but now you should have an app with Authentication, a User, some Tips and associations between them.

## Step 5.1 - The 'R' in CRUD - Creating an Index page
Lucky uses Actions to route requests. To create an action for the Tips index page, run:
```crystal
lucky gen.action.browser Tips::Index
```
Head to `http://localhost:3001/tips` to see the plaintext output of this file.

We want to render something a little more interesting than plaintext, so let's point edit `tipapp/src/actions/tips/index.cr` to point at a yet-to-be-created page called `Tips::IndexPage`, along with all of the current_user's tips:
```crystal
get "/tips" do
  html Tips::IndexPage, tips: UserQuery.new.preload_tips.find(current_user.id).tips
end
```

Now we can create the Tips::IndexPage at `tipapp/src/pages/tips/index_page.cr`. We'll render a simple table which iterates over the Tips using the following code:

```crystal
class Tips::IndexPage < MainLayout
  needs tips : Array(Tip)

  def content
    h1 "Tips"
    table do
      tr do
        th "ID"
        th "Category"
        th "Description"
      end
      tips.each do |tip|
        tr do
          td tip.id
          td tip.category
          td tip.description
        end
      end
    end
  end
end

```

Try out `http://localhost:3001/tips` to see your current_user's tips. This page should be ugly but working.

## Step 5.2 - The 'R' in CRUD - Creating a Show page
This step will be pretty similar to the Index page. To create an action for the Tips show page, run:
```crystal
lucky gen.action.browser Tips::Show
```
And update the generated `tipapp/src/actions/tips/show.cr` to point at a `Tips::Show` page, using the `:tip_id` as a param from the path:
```
class Tips::Show < BrowserAction
  get "/tips/:tipid" do
    html Tips::ShowPage, tip: TipQuery.new.user_id(current_user.id).find(tipid)
  end
end
```
The `Tips::Show` page should live in `tipapp/src/pages/tips/show_page.cr` and will have the following code:
```
class Tips::ShowPage < MainLayout
  needs tip : Tip

  def content
    h1 "Tip ##{tip.id}"

    para "Category: #{tip.category}"
    para "Description #{tip.description}"
  end
end
```
Visit the `tips` path with the ID of a Tip - eg. `http://localhost:3001/tips/2` and voila! A beautiful show page. Clearly, design is my passion.

## Step 6 - The 'C' in CRUD - Creating a Tip
Now things are getting interesting! We want to be able to create a new Tip by entering the information into a form at `http://localhost:3001/tips/new`.

First, we need an Action:
```crystal
lucky gen.action.browser Tips::New
```
And in that action at `tipapp/src/actions/tips/new.cr`, we want to create a new instance of `SaveTip` and pass it to the `Tips::NewPage`:
```crystal
class Tips::New < BrowserAction
  get "/tips/new" do
    html Tips::NewPage, operation: SaveTip.new
  end
end
```
The `Tips::NewPage` page should construct a form for the Tip like so:

```crystal
class Tips::NewPage < MainLayout
  needs operation : SaveTip

  def content
    h1 "Create New Tip"

    form_for(Tip::Create) do
      label_for(@operation.category, "Category")
      text_input(@operation.category, attrs: [:required])
      label_for(@operation.description, "Description")
      text_input(@operation.description, attrs: [:required])
      submit "Create Tip"
    end
  end
end
```
And just for something different, we need to permit the `category` and `description` params in the SaveTip Operation at `tipapp/src/operations/save_tip.cr`:
```crystal
class SaveTip < Tip::SaveOperation
  permit_columns category, description
end
```
Whew! Now navigate to the `http://localhost:3001/tips/new` , create your new tip and you should see it once you're redirected to the `http://localhost:3001/tips` page!

## Interlude - Gettin' Linky wit' it
With all these routes, the app is a bit of a pain to navigate around at the moment. Let's add a few links to make our lives a bit easier.
- In the `tipapp/src/pages/tips/index_page.cr` file, create a link to the 'New Tip' page using `link "New Tip", to: Tips::New`
- In the `tipapp/src/pages/tips/index_page.cr` file, in the table of Tips, create a link to each Tip's show page using `link "New Tip", to: Tips::New`
- In the MainLayout page at `tipapp/src/pages/main_layout.cr`, add a link to the Tips::Index page after the `render_signed_in_user` method so we can always get back to our Tips:
```crystal
text "    |    "
link "Tips Index Page", to: Tips::Index
```
Now it's less of a hassle to navigate around the app.

## Step 7 - The 'U' in CRUD - Updating a Tip
Once again, generate an Action:
```crystal
lucky gen.action.browser Tips::Edit
```
In that action, we want to get the ID of the Tip we're editing, and return that as an argument to a `Tips::EditPage` like so:
```crystal
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
```
While we're at it, we need to create an action for the route that we'll send the updated Tip information to, so create yet _another_ action:
```crystal
lucky gen.action.browser Tips::Update
```
And use this action to update the Tip or redirect back to the Edit page if we have errors:
```crystal
# tipapp/src/actions/tips/update.cr
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
```
Finally, we need to create the `Tips::EditPage` with a form for the Tip we're updating:
```crystal
# tipapp/src/pages/tips/edit_page.cr
class Tips::EditPage < MainLayout
  needs tip : Tip
  needs operation : SaveTip

  def content
    h1 "Edit Tip"

    form_for(Tips::Update.with(tip)) do
      label_for(@operation.category, "Category")
      text_input(@operation.category, attrs: [:required])
      label_for(@operation.description, "Description")
      text_input(@operation.description, attrs: [:required])
      submit "Update Tip"
    end
  end
end
```
So now put the ID of a Tip in your URL - eg `http://localhost:3001/tips/5/edit` - and confirm you can update it!
## Step 8 - The 'D' in CRUD - Deleting a Tip
The final step! Also quite a simple one. First, add a Delete action:
```crystal
lucky gen.action.browser Tips::Delete
```
And set up the action to destroy the Task based on its' ID:
```crystal
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
```
And that's it for the deletion! We'll confirm it's all working in the next section.
## Step 9 - Clean up and confirm it's working!
Our app, if the stars have aligned, should be up and working. We just need a few more little niceties before we can fully test it out.

Firstly, on the Tips::Index page, update the table to include links to the Show, Edit and Delete routes for each Tip:
```crystal
# tipapp/src/pages/tips/index_page.cr
...
td do
  ul do
    li do
      link "Edit", to: Tips::Edit.with(tip.id)
    end
    li do
      link "Show", to: Tips::Show.with(tip.id)
    end
    li do
      link "Delete", to: Tips::Delete.with(tip.id)
    end
  end
end
...
```
And on the Tips::Show page at, add the same links so that the Tip can be updated or deleted from there:
```
# tipapp/src/pages/tips/show_page.cr
ul do
  li do
    link "Edit", to: Tips::Edit.with(tip.id)
  end
  li do
    link "Show", to: Tips::Show.with(tip.id)
  end
  li do
    link "Delete", to: Tips::Delete.with(tip.id)
  end
end
```

And that's it!

To confirm it's working, go to the index page and create, update, and delete some tips.


## Fin

