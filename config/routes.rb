Rails.application.routes.draw do
  # Deviseの認証ルート
  devise_for :users

  # Reveal health status on /up ...
  get "up" => "rails/health#show", as: :rails_health_check

  # 管理者専用ルート (ID: 6)
  namespace :admin do
    root 'pages#home'
  
    get 'home', to: 'pages#home'
  
    get 'attendance_search_result', to: 'attendances#attendance_search_result'
    get 'absence_list',            to: 'attendances#absence_list'
    get 'absence_reason/:id',      to: 'attendances#absence_reason'
    get 'student_total/:id',       to: 'attendances#student_total'
  end
  

  # 学生用のルート (ID: 5)
  namespace :student do
    root "attendances#index"
    resources :attendances
  end
end