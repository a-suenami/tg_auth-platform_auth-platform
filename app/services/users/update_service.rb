# typed: false

module Users
  class UpdateService < BaseService
    def execute(user:)
      user.update(params)
      # zipcodeはハイフンを削除して保存する
      user&.contact_address&.zip_code = user&.contact_address&.zip_code&.delete('-') if user&.contact_address&.zip_code.present?
      user.save!

      # TODO: 電話番号が確認済みの場合、電話番号を変更できないように

      # aws event bridgeにイベント発行
      PublishEvents::PublishService.new.execute(user:, action_code: :update)

      true
    end
  end
end
