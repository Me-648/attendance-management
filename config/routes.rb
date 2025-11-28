Rails.application.routes.draw do
  # Deviseの認証ルート
  devise_for :users

  # Reveal health status on /up ...
  get "up" => "rails/health#show", as: :rails_health_check

  # 管理者専用ルート (ID: 6)
  namespace :admin do
    root "users#index"
    resources :users, only: [ :index, :show ]
    get "attendance_list", to: "users#attendance_list"
    get "absence_list", to: "users#absence_list"
  end

  # 学生用のルート (ID: 5)
  namespace :student do
    root "attendances#index"
    resources :attendances
  end
end
