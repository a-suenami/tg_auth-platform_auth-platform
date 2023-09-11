module API::V1::Internal
  class MeController < ApplicationController
    include CookieAuthable

    def show
      render :show
    end

    def destroy
      # 論理削除
      Users::DestroyService.new.execute(user: current_user)
      # ログアウト処理
      cookie_session.session_clear
      # aws sqsにイベント発行
      PublishEvents::PublishService.new.execute(user: current_user, action_code: 'deleted')
    end
  end
end
