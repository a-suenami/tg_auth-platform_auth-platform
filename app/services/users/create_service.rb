module Users
  class CreateService < BaseService

    def execute
      user = User.new(params)
      user.set_email_confirm_code
      # TODO: uidの生成方法を検討する
      user.uid = SecureRandom.uuid

      user.save
      user
    end
  end
end
