# Part 2: Library Users

## A Library Model

Let's add our second model a `Library` model that will later have books.

```bash
rails g model library name:string floor_count:integer floor_area:integer
```

We want a `user` to be able to join a library, but this means a `n:n` relationship. A user will have many libraries and library will have many users.

Thus we need a `library_user` model.


```ruby
rails g model library_user user:references library:references
```

In the future we can store other things on the `library_user` model that are relevant to someone's membership in a library.

We will also need two different controllers for each of these models. Let's start by being able to do CRUD with Libraries.

```
rails g controller libraries
```

### A Library Index

Let's add a route to be able to view all the libraries.

```ruby

Rails.application.routes.draw do
  ...
  get "/libraries", to: "libraries#index"
end
```

Then we need to add a `libraries#index` method to our libraries controller.

```ruby

class LibrariesController < ApplicationController

  def index
    @libraries = Library.all

    render :index
  end

end
```

Finally we can add a basic view for all libraries.


```html
<% @libraries.each do |library| %>
  <div>
    <h3><%= library.name %></h3>
  </div>
  <br>
<% end %>
```

### A New Library

To be able to add a new library we need a `libraries#new`.

```ruby

Rails.application.routes.draw do
...
  get "/libraries/new", to: "libraries#new", as: "new_library"
end

```

Then we add a `libraries#new` method.


```ruby
class LibrariesController < ApplicationController
...
  def new
    @library = Library.new

    render :new
  end
end
```

Finally, we can add a view for `new` library.

```html

<%= form_for @library do |f| %>
  <div>
    <%= f.text_field :name, placeholder: "Name" %>
  </div>
  <div>
    <%= f.number_field :floor_count, placeholder: "Floor Count" %>
  </div>
  <div>
    <%= f.number_field :floor_area, placeholder: "Floor Area" %>
  </div>
  <%= f.submit %>
<% end %>
```

This form has nowhere to go; if we try to submit it we get an error because there is no `POST /libraries` route.

Let's add one.


```ruby

Rails.application.routes.draw do
...
  post "/libraries", to: "libraries#create"
end
```

Then we need a corresponding `libraries#create`.

```ruby

class LibrariesController < ApplicationController

  def create
    library_params = params.require(:library).permit(:name, :floor_count, :floor_area)
    @library = Library.create(library_params)

    redirect_to libraries_path
  end
end
```

## CRUDing Libraries
We now have the ability to view all libraries (`libraries#index`).

Please take a moment to implement `libraries#show` on your own. You will need to create routes, controller actions, and html views.

Bonus: We recommend you also try to implement `edit`, `update`, `show`, and `delete`.

## Joining A Library
Before we get started joining a `library` and a `user` we need to wire together our `Library` and our `User` via associations.

```ruby
class User < ActiveRecord::Base
  has_many :library_users
  has_many :libraries, through: :library_users

  ...
end
```

And we create the reciprocal associations in our `Library` model.

```ruby
class Library < ActiveRecord::Base
  has_many :library_users
  has_many :users, through: :library_users
end
```

And we need to associate `LibraryUser` with `Library` and `User` too!


```ruby
class LibraryUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :library
end
```

You should now test this out in the console.

```bash
> user = User.first
> user.libraries
#=> []
> sfpl = Library.create({name: "SFPL"}) # San Francisco Public Library
> sfpl.users
#=> []
> sfpl.users.push(user)
> sfpl.users
#=> [ <#User ... @id=1> ]
> LibraryUser.count
#=> 1
> reload!
> user.libraries
#=> [ <#Library ... @name="SFPL" @id=1> ]
```
In order for us to have users join libraries, we need to first create a `library_users` controller.

```bash
rails g controller library_users
```

We want to be able to view all user memberships to a library. We can specify this as a url like `/users/:user_id/libraries`.

```ruby

Rails.application.routes.draw do
  ...
  get "/users/:user_id/libraries", to: "library_users#index", as: "user_libraries"

end
```

We also neeed the corresponding `index` method in the `library_users` controller


```ruby
class LibraryUsersController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    @libraries = @user.libraries

    render :index
  end
end
```

Then we can have the `index` action list the user's libraries (`app/views/library_users/index.html.erb`):

```html

<div><%= @user.first_name %> is a member of the following libraries</div>

<ul>
  <% @libraries.each do |lib| %>
    <li><%= lib.name %></li>
  <% end %>
</ul>
```

We can test this by going to `localhost:/users/1/libraries`. If you want, you can test that this is working by launching your `rails console` and adding a library to a user.


## Add A User Lib

We should make a button that allows a user to `join` a library!

Let's go back to the `libraries#index` view and add a button to do just that.

```html

<% @libraries.each do |library| %>
  <div>
    <h3><%= library.name %></h3>
    <% if current_user %>
      <%= button_to "Join", library_users_path(library) %>
    <% end %>
  </div>
  <br>
<% end %>
```

We don't have an endpoint yet that allows a user to join a library, so let's add that now so that our form will work.


```ruby
Rails.application.routes.draw do
  ...
  get "/users/:user_id/libraries", to: "library_users#index", as: "user_libraries"
  post "/libraries/:library_id/users", to: "library_users#create", as: "library_users"
end

```

Then we need to add a `create` action in `LibraryUsersController` that adds the user to the library.


```ruby
class LibraryUsersController < ApplicationController

  ...

  def create
    @library = Library.find(params[:library_id])
    @library.users.push(current_user)

    redirect_to current_user
  end
end

```


## Authorization

Let's say that in order to visit a `users#show` page you have to be logged in. We'll use a special `before_action` to check for this.

```ruby
class UsersController < ApplicationController

  before_action :logged_in?, only: [:show]

  ...

  def show
    @user = User.find(params[:id])
    render :show
  end

end
```

What other endpoints should be protected? Should an unauthenticated user be able to CRUD resources? Think about POST, PUT, and DELETE!

### Cleanup

Before moving on to bonuses, take a moment to make your site more user friendly. Link pages together so that a user can navigate more easily from their profile to their list of libraries, and from the library index to an individual library. Consider adding a better menu/navbar to make navigation easier.

### Bonuses

* Can you add books to the application?
    - For starters, just create a `Book` model and the associated views.
* Can you add books to the library?
    - What kind of a relationship is that? Where would foreign keys like `book_id` and `library_id` live in your database tables?
