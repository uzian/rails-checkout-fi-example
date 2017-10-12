Rails.application.routes.draw do
  root to: "payments#index"
  resources :payments do  
    member do    
      get :checkout, :cancel
    end    
  end
end
