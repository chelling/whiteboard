Whiteboard::Application.routes.draw do
  root :to => "home#index"
  
  match "/scores" => "games#scores"
  match "/pickem" => "pickem_picks#scores"
  match "/pickem_pick/update_picks" => "pickem_picks#update_picks"
  match "/stats" => "pickem_picks#stats"
  match "/fooicide" => "fooicide_picks#scores"
  match "/fooicide/rules" => "fooicide_picks#rules"
  match "/fooicide/update_picks" => "fooicide_picks#update_picks"
  match "/winpool/:id" => "win_pool_picks#win_pool"
  match "/winpool/:id/pick_team" => "win_pool_picks#pick_team"
  match "/user_wagers/:year/:week/:user_id" => "home#user_wagers"
  match "/user_wagers/:year/:user_id" => "home#user_wagers"
  match "/update_games" => "pickem_picks#update_games"

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

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
