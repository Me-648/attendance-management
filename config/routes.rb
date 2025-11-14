# config/routes.rb

Rails.application.routes.draw do
  devise_for :users
  
  # Reveal health status on /up ...
  get "up" => "rails/health#show", as: :rails_health_check
  get "health" => "rails/health#show", as: :rails_health_check

  # =======================================================
  # 管理者専用のルート (ID: 6)
  # =======================================================
  namespace :admin do
    # /admin/ にアクセスしたら admin/users#index へ
    root 'users#index', as: 'root' 
    
    # /admin/users へのルートを作成
    resources :users, only: [:index, :show]
  end

  # =======================================================
  # 学生用のルート (ログイン後画面) (ID: 5)
  # =======================================================
  # resource :student は /student のルートを作成します
  # [重要] 'resources:' から 'resource :' に修正し、コロンとスペースも修正
  resource :student, only: [] do 
     # /student にアクセスしたら attendances#index へ
     root 'attendances#index', as: 'root'

    # 出欠を登録するためのルート /student/attendances
    resources :attendances, only: [:create]
  end
end