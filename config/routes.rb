Whiteboard::Application.routes.draw do
  root to: "home#index"
  
  get "/scores", to: "games#scores"
  get "/pickem", to: "pickem_picks#scores"
  get "/pickem_pick/update_picks", to:"pickem_picks#update_picks"
  get "/stats", to: "pickem_picks#stats"
  get "/fooicide", to: "fooicide_picks#scores"
  get "/fooicide/rules", to: "fooicide_picks#rules"
  get "/fooicide/update_picks", to: "fooicide_picks#update_picks"
  get "/winpool/:id", to: "win_pool_picks#win_pool"
  get "/winpool/:id/pick_team", to: "win_pool_picks#pick_team"
  get "/user_wagers/:year/:week/:user_id", to: "home#user_wagers"
  get "/user_wagers/:year/:user_id", to: "home#user_wagers"
  get "/update_games", to: "pickem_picks#update_games"

  # match "/thirtyeight" => "thirty_eights#scores"
  # match "/thirtyeight" => "thirty_eights#rules"

  
  resources :home
  resources :thirty_eights
  resources :fooicide_picks
  resources :pickem_picks
  resources :teams
  resources :games
  resources :win_pool_picks
  resources :stadiums

  devise_for :users do get '/users/sign_out' => 'devise/sessions#destroy' end
end
