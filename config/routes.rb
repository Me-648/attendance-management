# config/routes.rb

Rails.application.routes.draw do
  devise_for :users

  # devise_scope を使って、認証関連のルートをカスタマイズします
  devise_scope :user do
    # ログアウト後のリダイレクト先をログインページに設定
    get "users/sign_out" => "devise/sessions#destroy"

    # アプリケーションのルートパス (/) をログインページに設定
    root "devise/sessions#new"
  end
  
  # Reveal health status on /up ...
  get "up" => "rails/health#show", as: :rails_health_check

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
  # `/student` というパスのグループを作成します
  scope '/student', as: 'student' do
    # /student へのGETリクエストを attendances#index につなぎ、`student_root_path` という名前をつけます
    root to: 'attendances#index', as: 'root'
    # /student/attendances へのPOSTリクエストを attendances#create につなぎます
    resources :attendances, only: [:create]
  end
end