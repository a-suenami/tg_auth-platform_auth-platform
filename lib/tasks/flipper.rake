# frozen_string_literal: true

namespace :flipper do
  desc 'Setup feature flags'
  task setup: :environment do
    # 管理画面の新UI
    Flipper.add(:admin_new_ui)
    puts 'Feature flag :admin_new_ui has been added'
  end
end
