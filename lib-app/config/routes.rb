# == Route Map
#
#      Prefix Verb URI Pattern              Controller#Action
#        root GET  /                        users#index
#    new_user GET  /users/new(.:format)     users#new
#       users POST /users(.:format)         users#create
#        user GET  /users/:id(.:format)     users#show
#       login GET  /login(.:format)         sessions#new
#      logout GET  /logout(.:format)        sessions#destroy
#    sessions POST /sessions(.:format)      sessions#create
#   libraries GET  /libraries(.:format)     libraries#index
# new_library GET  /libraries/new(.:format) libraries#new
#             POST /libraries(.:format)     libraries#create
#

Rails.application.routes.draw do
  root to: 'users#index'

  get '/users/new', to: 'users#new', as: 'new_user'
  post '/users/', to: "users#create"
  get '/users/:id', to: 'users#show', as: 'user'

  get '/login', to: 'sessions#new'
  get '/logout', to: 'sessions#destroy'
  post '/sessions', to: 'sessions#create'

  get '/libraries', to: 'libraries#index'
  get '/libraries/new', to: 'libraries#new', as: 'new_library'
  post '/libraries', to: 'libraries#create'

  get '/users/:user_id/librareis', to: 'library_users#index', as: 'user_libraries'

end
