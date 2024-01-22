# typed: false

module Users
  class UpdateService < BaseService
    def execute(user:)
      # first_name, birth_date, genderは一度登録したら変更不可
      params[:user_profile_attributes][:first_name] = user.user_profile&.first_name if user.user_profile&.first_name.present?
      params[:user_profile_attributes][:first_name_kana] = user.user_profile&.first_name_kana if user.user_profile&.first_name_kana.present?
      params[:user_profile_attributes][:birth_date] = user.user_profile&.birth_date if user.user_profile&.birth_date.present?
      params[:user_profile_attributes][:gender] = user.user_profile&.gender if user.user_profile&.gender.present?

      user.update!(params)

      # TODO: 電話番号が確認済みの場合、電話番号を変更できないように

      # aws event bridgeにイベント発行
      PublishEvents::PublishService.new.execute(user:, action_code: :update)

      true
    end
  end
end
