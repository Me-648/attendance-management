# config/routes.rb

Rails.application.routes.draw do
  # Deviseの認証ルート
  devise_for :users

  # Rails 標準ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check

  # =======================================================
  # ログイン前トップページ（/）
  # =======================================================
  # ルートパスをDeviseのログイン画面に設定 (Deviseスコープ内で定義が必要)
  devise_scope :user do
    root "devise/sessions#new", as: :authenticated_root
  end

  # =======================================================
  # 管理者専用ルート /admin
  # =======================================================
  namespace :admin do
    # /admin にアクセスしたら管理者トップ (Admin::Users#index)
    # after_sign_in_path_for でリダイレクトされるパス
    root "users#index", as: "root"

    # 管理者・ユーザー一覧 (現時点では index と show のみ)
    resources :users, only: [:index, :show]
  end

  # =======================================================
  # 学生用 /student
  # =======================================================
  # resource :student は単数形リソースで、/student のルートを生成します
  resource :student, only: [] do
    # /student にアクセス → Attendances#index
    # after_sign_in_path_for でリダイレクトされるパス
    root "attendances#index", as: "root"

    # 出欠登録用（例：POST /student/attendances）
    resources :attendances, only: [:create]
  end

end