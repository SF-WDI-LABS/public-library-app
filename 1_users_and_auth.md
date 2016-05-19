# Part 1: Users & Auth

### Setup

Create a new rails app:

```bash
rails new lib_app -T -d postgresql
cd lib_app
```

Create the databases:
``` bash
rake db:create
```



## Routes First

Let's start with the routes for a user.

`config/routes.rb`

```ruby
Rails.application.routes.draw do
  root to: "users#index"
end
```

We can look at how these routes are interpreted by Rails.

```bash
rake routes
```

Which gives us the following routes:

```bash
Prefix Verb URI Pattern      Controller#Action
  root GET  /                users#index
```

Note the special `Prefix` column this will be of great use later.

Well the even bigger question now is **what to do next?** The truth is we don't have a `users#index`. We don't even have a `UsersController`. Let's practice using our `rails generate` skills.

```bash
rails g controller users
```

This does something like the following:

```bash
***   create  app/controllers/users_controller.rb
      invoke  erb
***   create    app/views/users
      invoke  helper
 **   create    app/helpers/users_helper.rb
      invoke  assets
      invoke    coffee
 **    create      app/assets/javascripts/users.coffee
      invoke    scss
 **   create      app/assets/stylesheets/users.scss
```

Note the special `create` statements here. The `***` ones are the most important. It creates the `users_controller.rb` file and the `views/users` directory.

Now that we have a `users_controller.rb` we should add our `users#index` method.

```ruby
class UsersController < ApplicationController

  # grab the users
  def index
    @users = User.all
    render :index
  end

end
```

Then we need to actually create an `index.html.erb`:

```bash
touch app/views/users/index.html.erb
```

Then we can go ahead and add something special to our `index`:

```html
<h1>Welcome to Users Index.</h1>

<div>
There are currently <%= @users.length %> signed_up
</div>
```

**But wait!** If you go to `localhost:3000` after this step (like you should be!), we have a problem. No User model.

Let's generate a `user` model.

```bash
rails g model user email:string first_name:string last_name:string password_digest:string
```

Then go ahead and verify that the migration looks correct:

`db/migrate/*_create_users.rb`

```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :password_digest

      t.timestamps null: false
    end
  end
end
```

And it does! Whoot! We're ready to migrate!

```bash
rake db:migrate
```

Ok, now we should see `0` users signed_up. We should change that!

```ruby

Rails.application.routes.draw do
  root to: "users#index"

  get "/users", to: "users#index", as: "users"

  get "/users/new", to: "users#new", as: "new_user"
end
```

With the following output after we `rake routes`:

```bash
  Prefix Verb URI Pattern          Controller#Action
    root GET  /                    users#index
new_user GET  /users/new(.:format) users#new
```

We don't have a `users#new` so let's create one.


```ruby

class UsersController < ApplicationController

  def new
    # we need to make
    # a new user
    # to pass to the
    # form later
    @user = User.new
    render :new
  end

end

```

Then we can continue on to creating a `new.html.erb`

```html


Sign Up

<%= form_for @user do |f| %>
  <div>
    <%= f.text_field :first_name, placeholder: "First Name" %>
  </div>
  <div>
    <%= f.text_field :last_name, placeholder: "Last Name" %>
  </div>
  <div>
    <%= f.text_field :email, placeholder: "Email" %>
  </div>
  <div>
    <%= f.password_field :password, placeholder: "Password" %>
  </div>
  <%= f.submit "Sign Up" %>
<% end %>
```

Which renders a form like the following (note the authenticity token):

```html
<!-- DO NOT COPY THIS CODE -->
Sign Up

<form class="new_user" id="new_user" action="/users" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="authenticity_token" value="5989PH35p43aagbgiuA/C02p8uD6bLmZR+GCLd01lYPmBOSGLNoHMnEGuZXyzHjnTsMvW6h5860tN6CswMsU5A==" />
  <div>
    <input placeholder="First Name" type="text" name="user[first_name]" id="user_first_name" />
  </div>
  <div>
    <input placeholder="Last Name" type="text" name="user[last_name]" id="user_last_name" />
  </div>
  <div>
    <input placeholder="Email" type="text" name="user[email]" id="user_email" />
  </div>
  <div>
    <input placeholder="Password" type="password" name="user[password]" id="user_password" />
  </div>
  <input type="submit" name="commit" value="Sign Up" />
</form>
```

Note here the correlation between the key we put into `f.text_field` and `name="..."`.

Also note where this form is going

```html
<form class="new_user" id="new_user" action="/users" accept-charset="UTF-8" method="post">
```

It looks like this form is sending `POST /USERS`, but we don't have that route so we have to **create** it.


```ruby
Rails.application.routes.draw do
  root to: "users#index"

  get "/users", to: "users#index", as: "users"
  get "/users/new", to: "users#new", as: "new_user"
  post "/users", to: "users#create"
end
```

Then we need to add that method.

```ruby
class UsersController < ApplicationController

  ...

  def create
    user_params = params.require(:user).permit(:first_name, :last_name, :email, :password)
    @user = User.create(user_params)

    redirect_to root_path
  end

end
```

Now when you submit the form you get the following error:

```
ActiveRecord::Unknown
AttributeError in UsersController#create

unknown attribute 'password' for User.
```

This is because we only have a `password_digest`. We also haven't setup our application to help users sign up at all. This is a good time to start adding our authentication logic.


Uncomment your `bcrypt` in your `Gemfile`

`Gemfile`

```ruby
...

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

...
```

Then we can add `has_secure_password` to our user model application.

```ruby
class User < ActiveRecord::Base
  has_secure_password
end
```

Now when we post the form for the user you'll see the user being created. The difference now is the `password_digest` is being properly hashed.

Now we want to add a route to `GET /users/:id`.

```ruby

Rails.application.routes.draw do
  root to: "users#index"

  get "/users", to: "users#index", as: "users"
  get "/users/new", to: "users#new", as: "new_user"
  post "/users", to: "users#create"
  get "/users/:id", to: "users#show", as: "user"
end

```

We want to add a `users#show` page.

```ruby

class UsersController < ApplicationController

  def show
    @user = User.find_by_id(params[:id])
    render :show
  end

end

```

Then we need a `show.html.erb` to display the users information.

```html

<div>
  Welcome, <%= @user.email %>
</div>

```

Let's test what we've got so far by creating a user.

Open the rails console and seed a user:

```bash
rails c
> user = User.create(
>  email: 'test@test.com',
>  first_name: "test",
>  last_name: "subject",
>  password: "123"
>)
```

Or you can add a user using the form you just created at `/users/new`.

Test your views before moving on.

## Users Sign In

Now that we can create a user we need to be able to sign a user in.

Signing in and signing out is a concern of a new controller, the sessions controller.


```
rails g controller sessions --no-assets
```

Note this will create both `sessions_controller.rb` and `sessions_helper.rb` (and it will skip adding `app/assets/javascripts/sessions.coffee` and `app/assets/stylesheets/sessions.scss`).

> Pro-Tip: You can "undo" your `rails generate` command by using `rails destroy controller sessions`

Now we should use the `session_helper` by adding our own logic to it.


```ruby

module SessionsHelper

  def login(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def logged_in?
    if current_user == nil
      redirect_to new_session_path
    end
  end

  def logout
    @current_user = session[:user_id] = nil
  end

end
```

These methods will help avoid code bloat when signing in and out. Before we can use the methods though we have to add these methods to the `ApplicationController`.

```ruby

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper
end

```


Now, we are ready to continue. Let's add some routes to `sign_in`.


```ruby

Rails.application.routes.draw do

  ...

  get "/login", to: "sessions#new"

end

```


Now we need to add the `sessions#new`.


```ruby

class SessionsController < ApplicationController

  def new
    @user = User.new
    render :new
  end

end
```

Then we need to add a view for the `sessions/new.html.erb`.

```bash
touch app/views/sessions/new.html.erb
```

Then very similarly to what we did before for sign up, we create a form for sign in.

```html

Login

<%= form_for @user, url: "/sessions", method: "post" do |f| %>
  <div>
    <%= f.text_field :email, placeholder: "Email" %>
  </div>
  <div>
    <%= f.password_field :password, placeholder: "Password" %>
  </div>
  <%= f.submit "Sign In" %>
<% end %>

```

Before we go forward let's go ahead and drop in a very key piece of confirmation logic into our `user` model.

```ruby
class User < ActiveRecord::Base
  has_secure_password

  def self.confirm(params)
    @user = User.find_by({email: params[:email]})
    @user.try(:authenticate, params[:password])
  end
end
```

You can test this is working by opening your rails console:

```bash
rails c
> reload! # use this if you already had the console open
> User.confirm({email: "test@test.com", password: "123"})
> User.confirm({email: "test@test.com", password: "WRONG"})
```

Note that the form is getting submited to `POST /sessions`. We don't have a `sessions#create` however or a route to handle the post.

```ruby

Rails.application.routes.draw do

  get "/login", to: "sessions#new"

  post "/sessions", to: "sessions#create"

end
```

Now let's add the `sessions#create`

```ruby

class SessionsController < ApplicationController

  def create
    user_params = params.require(:user).permit(:email, :password)
    @user = User.confirm(user_params)
    if @user
      login(@user)
      redirect_to @user
    else
      redirect_to login_path
    end
  end
end
```


Then when we try to login let's see what happens. Do you see a welcome? If so you're ready to continue otherwise you should start the long work of debugging.

### Finishing Sign Up

After a user is signed up they should be logged in.

```ruby

class UsersController < ApplicationController

  def create
    user_params = params.require(:user).permit(:first_name, :last_name, :email, :password)
    @user = User.create(user_params)
    login(@user) # <-- login the user
    redirect_to @user # <-- go to show
  end

end

```

We do not yet have a logout method (`sessions#destroy`). As a last resort, you can always delete individual browser cookies (*Chrome Developer Console > Resources > Cookies > localhost*). But we do have a helper function (`logout`) that will destroy the user's session. Let's create a `/logout` route and corresponding action `sessions#destroy`.

```ruby
Rails.application.routes.draw do
  ...
  get "/login", to: "sessions#new"
  get "/logout", to: "sessions#destroy" # <-- strictly speaking this isn't RESTful (it should be a DELETE not GET), but it's super conveient to do it this way
  post "/sessions", to: "sessions#create"
end
```

The `sessions#destroy` controller action needs to clear the `user_id` from the session:

```ruby
class SessionsController < ApplicationController
    ...

    def destroy
      logout # this method lives in the SessionsHelper!
      redirect_to root_path
    end

end
```

Now we can go directly to `/logout` to logout (delete the session user_id), but we should also have a "Logout" button. Even better would be a navbar with all the login/signup/logout options. Let's add a navbar to `views/layouts/application.html.erb` with some conditional logic, depending on whether the user is logged in:

```html
<!--<html>-->
<!--<body>-->

<ul>
  <% if current_user %>
    <li><%= link_to "Profile", user_path(current_user) %></li>
    <li><%= link_to "Log Out", logout_path %></li>
  <% else %>
    <li><%= link_to "Create Account", new_user_path %></li>
    <li><%= link_to "Log In", login_path %></li>
  <% end %>
</ul>

<!--<%= yield %>-->

<!--</body>-->
<!--</html>-->
```

Go ahead and check all your links are working (try it both logged in and logged out).

As a final touch, let's add "flash" messages to inform the user that they are "Successfully logged in" and "Successfully logged out".

``` ruby
class SessionsController < ApplicationController
  ...

  def create
    user_params = params.require(:user).permit(:email, :password)
    @user = User.confirm(user_params)
    if @user
      login(@user)
      flash[:notice] = "Successfully logged in."      # <--- Add this flash notice
      redirect_to @user
    else
      flash[:error] = "Incorrect email or password."  # <--- Add this flash error
      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Successfully logged out."        # <--- Add this flash notice
    redirect_to root_path
  end

end
```

And let's make sure to update `views/layouts/application.html.erb` to display the messages.

``` html
...

<% flash.each do |name, msg| %>
  <p>
    <small> <%= name.capitalize %>: <%= msg %> </small>
  </p>
<% end %>

<!--<%= yield %>-->

<!--</body>-->
<!--</html>-->
```

Nice work! We're finished with Auth!

Now delete this app and do it again!!! Once you've completed this auth 2x, then move on to the refactoring section below.

## Refactoring Params

Every time we take in a lot of params in a controller it's tedious to write out.

```ruby
class UsersController < ApplicationController

  ...

  def create
    user_params = params.require(:user).permit(:first_name, :last_name, :email, :password)
    @user = User.create(user_params)
    login(@user)
    redirect_to @user
  end

  ...

end

```


You can utilize a private method for doing this. Let's refactor.


```ruby
class UsersController < ApplicationController

  ...

  def create
    @user = User.create(user_params) # calls user_params method
    login(@user)
    redirect_to @user
  end

  ...

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end
end

```

### Exercise

* Private methods like `user_params` are simple to implement and give us cleaner looking code. Rewrite `sessions#create` using this idea.

### Bonus

1. On the profile page, display when the user created their account. To format the date, use Ruby's built in time formatter, [strftime](http://ruby-doc.org/core-2.2.0/Time.html#method-i-strftime).

1.  Right now, all the user profile pages can be seen by anyone no matter if they're logged in or not. Make it so that `/users/:id` can only be viewed if that is the profile of the currently logged in user, otherwise, redirect to home.
  <details>
    <summary>HINT</summary>
    use the `current_user` object from the session helper
  </details>

1. Create another route only available to logged in users. Call it whatever you'd like!

### Super cray bonus
* Right now, you can create users with the same email. Create a validation on the user model that disallows this behavior. Consult [these docs](http://guides.rubyonrails.org/active_record_validations.html).
