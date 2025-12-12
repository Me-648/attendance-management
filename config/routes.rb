Rails.application.routes.draw do
  # Deviseの認証ルート
  devise_for :users

  # Reveal health status on /up ...
  get "up" => "rails/health#show", as: :rails_health_check

  # 管理者専用ルート
  namespace :admin do
    root "pages#home"

    get "home", to: "pages#home"
    resources :users, only: [ :index ]
    get "attendances/by_period", to: "attendances#by_period"
    get "attendances/:id/reason", to: "attendances#reason", as: "attendance_reason"
    get "attendances/:id/total", to: "attendances#total", as: "attendance_total"
  end


  # 学生用のルート (ID: 5)
  namespace :student do
    root "attendances#index"
    resources :attendances
  end
end
