Rails.application.routes.draw do
  scope module: :user_area do
    # ログイン
    get 'login', to: 'logins#new', as: :login
    post 'login', to: 'logins#create'

    # サインアップ（複数ステップ）
    get 'sign_up', to: 'sign_ups#new', as: :sign_up
    post 'sign_up', to: 'sign_ups#create'
    get 'sign_up/verify_email', to: 'sign_ups#verify_email', as: :sign_up_verify_email
    post 'sign_up/verify_email', to: 'sign_ups#verify_email_submit'
    get 'sign_up/set_password', to: 'sign_ups#set_password', as: :sign_up_set_password
    post 'sign_up/set_password', to: 'sign_ups#set_password_submit'
    get 'sign_up/phone_number', to: 'sign_ups#phone_number', as: :sign_up_phone_number
    post 'sign_up/phone_number', to: 'sign_ups#phone_number_submit'
    get 'sign_up/verify_sms', to: 'sign_ups#verify_sms', as: :sign_up_verify_sms
    post 'sign_up/verify_sms', to: 'sign_ups#verify_sms_submit'
    post 'sign_up/resend_email', to: 'sign_ups#resend_email', as: :sign_up_resend_email
    post 'sign_up/resend_sms', to: 'sign_ups#resend_sms', as: :sign_up_resend_sms

    # SMS MFA（ログイン時）
    get 'mfa/sms', to: 'mfa#new', as: :mfa_sms
    post 'mfa/sms', to: 'mfa#create'
    post 'mfa/sms/resend', to: 'mfa#resend', as: :mfa_sms_resend

    # ログアウト
    get 'logout', to: 'sessions#logout', as: :logout

    # マイページ
    get 'my', to: 'mypage#show', as: :mypage
    get 'my/profile', to: 'profiles#edit', as: :edit_profile
    patch 'my/profile', to: 'profiles#update', as: :profile
    get 'my/memberships', to: 'memberships#my_memberships', as: :my_memberships

    # クレジットカード
    get 'my/credit_card', to: 'credit_cards#show', as: :credit_card
    get 'my/credit_card/new', to: 'credit_cards#new', as: :new_credit_card
    get 'my/credit_card/complete', to: 'credit_cards#complete', as: :complete_credit_card
    delete 'my/credit_card', to: 'credit_cards#destroy'

    # メンバーシッププラン
    get 'memberships', to: 'memberships#index', as: :membership_plans
    get 'memberships/:id', to: 'memberships#show', as: :membership_plan
    post 'memberships/:id/purchase', to: 'memberships#purchase', as: :purchase_membership_plan

    resources :authorizations, only: [] do
      collection do
        get :relaunch
      end
    end
    resources :account_locks, only: [] do
      collection do
        get :unlock
      end
    end
    resources :sessions, only: [] do
      collection do
        get :logout  # 後方互換性のため残す
      end
    end

    resources :federated_authentications, only: [] do
      collection do
        get 'oauth/redirect/:provider', to: 'federated_authentications#redirect', as: :oauth_redirect
        get 'oauth/callback', to: 'federated_authentications#callback', as: :oauth_callback
      end
    end
  end
end
