Rails.application.routes.draw do
  root to: "users#index"

  get "/users", to: "users#index", as: "users"
  get "/users/new", to: "users#new", as: "new_user"
  post "/users", to: "users#create"
  get "/users/:id", to: "users#show", as: "user"

  get "/login", to: "sessions#new"
  get "/logout", to: "sessions#destroy"
  post "/sessions", to: "sessions#create"

  get "/libraries", to: "libraries#index", as: "libraries"
  get "/libraries/new", to: "libraries#new", as: "new_library"
  post "/libraries", to: "libraries#create"
  get "/libraries/:id", to: "libraries#show", as: "library"

  get "/users/:user_id/libraries", to: "library_users#index", as: "user_libraries"
  post "/libraries/:library_id/users", to: "library_users#create", as: "library_users"
  post '/library_users', to: 'library_users#create', as: "better_library_users"

end
