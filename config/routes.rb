Rails.application.routes.draw do
  devise_for :users

  # Reveal health status on /up ...
  get "up" => "rails/health#show", as: :rails_health_check

  # 管理者専用ルート (ID: 6)
  namespace :admin do
    root "users#index"
    resources :users, only: [ :index, :show ]
  end

  # 学生用のルート (ID: 5)
  namespace :student do
    root "attendances#index"
    resources :attendances do
      get :form, on: :collection
    end

    if Rails.env.development?
      namespace :development do
        post "time_travel", to: "time_travel#update", as: :time_travel
      end
    end
  end
end
