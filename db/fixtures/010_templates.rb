# frozen_string_literal: true

# Template fixtures - テンプレート管理サンプルデータ
# 使用方法: rake db:seed_fu

tenant_id = 'sample'

# 1. バースデーテンプレート (Draft - 下書き)
Template.seed(:id) do |s|
  s.id = '00000000-0000-0000-0000-000000000001'
  s.tenant_id = tenant_id
  s.name = 'バースデーテンプレート'
  s.created_at = 1.month.ago
  s.updated_at = 1.day.ago
end

Template::Mail.seed(:id) do |s|
  s.id = '00000000-0000-0000-0001-000000000001'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000001'
  s.title = 'お誕生日おめでとうございます！'
  s.body = '{{name}}様' + "\n\nお誕生日おめでとうございます！\n\n日頃のご愛顧に感謝して、特別なクーポンをお送りします。"
  s.created_at = 1.month.ago
  s.updated_at = 1.day.ago
end

# Version history for Template 1
Template::Mail::Version.seed(:id) do |s|
  s.id = '00000000-0000-0000-0001-000000000011'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000001'
  s.version = 1
  s.title = 'お誕生日おめでとう'
  s.body = "前回公開版の内容です"
  s.public_started_at = 3.months.ago
  s.created_at = 3.months.ago
end

# 2. ブログ更新テンプレート (Published - 公開中)
Template.seed(:id) do |s|
  s.id = '00000000-0000-0000-0000-000000000002'
  s.tenant_id = tenant_id
  s.name = 'ブログ更新テンプレート'
  s.created_at = 2.months.ago
  s.updated_at = 1.month.ago
end

Template::Mail.seed(:id) do |s|
  s.id = '00000000-0000-0000-0002-000000000002'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000002'
  s.title = '新しいブログ記事が投稿されました'
  s.body = '{{name}}様' + "\n\n新しいブログ記事「" + '{{article_title}}' + "」が投稿されました。\n\nぜひご覧ください。"
  s.created_at = 2.months.ago
  s.updated_at = 1.month.ago
end

# Many versions for Template 2 (simulating 100 versions)
100.times do |i|
  Template::Mail::Version.seed(:id) do |s|
    s.id = format('00000000-0000-0000-0002-%012d', i + 1)
    s.tenant_id = tenant_id
    s.template_id = '00000000-0000-0000-0000-000000000002'
    s.version = i + 1
    s.title = "ブログ更新 v#{i + 1}"
    s.body = "Version #{i + 1} content"
    s.public_started_at = (100 - i).months.ago
    s.created_at = (100 - i).months.ago
  end
end

# 3. チケット更新テンプレート (Scheduled - 公開予約中)
Template.seed(:id) do |s|
  s.id = '00000000-0000-0000-0000-000000000003'
  s.tenant_id = tenant_id
  s.name = 'チケット更新テンプレート'
  s.created_at = 1.week.ago
  s.updated_at = 1.day.ago
end

Template::Mail.seed(:id) do |s|
  s.id = '00000000-0000-0000-0003-000000000003'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000003'
  s.title = 'サポートチケットが更新されました'
  s.body = '{{name}}様' + "\n\nあなたのサポートチケット #" + '{{ticket_id}}' + " が更新されました。\n\n内容をご確認ください。"
  s.created_at = 1.week.ago
  s.updated_at = 1.day.ago
end

# Versions for Template 3 (12 versions + 1 scheduled)
12.times do |i|
  Template::Mail::Version.seed(:id) do |s|
    s.id = format('00000000-0000-0000-0003-%012d', i + 1)
    s.tenant_id = tenant_id
    s.template_id = '00000000-0000-0000-0000-000000000003'
    s.version = i + 1
    s.title = "チケット更新 v#{i + 1}"
    s.body = "Version #{i + 1}"
    s.public_started_at = (12 - i).weeks.ago
    s.created_at = (12 - i).weeks.ago
  end
end

# Add scheduled version (v13) with future date
Template::Mail::Version.seed(:id) do |s|
  s.id = '00000000-0000-0000-0003-000000000013'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000003'
  s.version = 13
  s.title = 'サポートチケットが更新されました'
  s.body = '{{name}}様' + "\n\nあなたのサポートチケット #" + '{{ticket_id}}' + " が更新されました。\n\n内容をご確認ください。"
  s.public_started_at = 1.week.from_now # Scheduled
  s.created_at = 1.day.ago
end

# 4. キャンペーンテンプレート (Published)
Template.seed(:id) do |s|
  s.id = '00000000-0000-0000-0000-000000000004'
  s.tenant_id = tenant_id
  s.name = 'キャンペーンテンプレート'
  s.created_at = 1.month.ago
  s.updated_at = 2.weeks.ago
end

Template::Mail.seed(:id) do |s|
  s.id = '00000000-0000-0000-0004-000000000004'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000004'
  s.title = '期間限定キャンペーンのお知らせ'
  s.body = '{{name}}様' + "\n\n期間限定のキャンペーンを実施中です！\n\nこの機会にぜひご利用ください。"
  s.created_at = 1.month.ago
  s.updated_at = 2.weeks.ago
end

# 2 versions
2.times do |i|
  Template::Mail::Version.seed(:id) do |s|
    s.id = format('00000000-0000-0000-0004-%012d', i + 1)
    s.tenant_id = tenant_id
    s.template_id = '00000000-0000-0000-0000-000000000004'
    s.version = i + 1
    s.title = "キャンペーン v#{i + 1}"
    s.body = "Campaign version #{i + 1}"
    s.public_started_at = (i + 1).months.ago
    s.created_at = (i + 1).months.ago
  end
end

# 5. チケット先行テンプレート (Draft - まだ空)
Template.seed(:id) do |s|
  s.id = '00000000-0000-0000-0000-000000000005'
  s.tenant_id = tenant_id
  s.name = 'チケット先行テンプレート'
  s.created_at = 3.days.ago
  s.updated_at = 3.days.ago
end

Template::Mail.seed(:id) do |s|
  s.id = '00000000-0000-0000-0005-000000000005'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000005'
  s.title = nil # Empty draft
  s.body = nil
  s.created_at = 3.days.ago
  s.updated_at = 3.days.ago
end

# 1 version
Template::Mail::Version.seed(:id) do |s|
  s.id = '00000000-0000-0000-0005-000000000011'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000005'
  s.version = 1
  s.title = 'チケット先行販売'
  s.body = 'First version'
  s.public_started_at = 1.month.ago
  s.created_at = 1.month.ago
end

# ============================================================
# Mail Template Histories
# ============================================================

# Template 1 - Draft: draft_created + draft_updated
Template::Mail::History.seed(:id) do |s|
  s.id = '10000000-0000-0000-0001-000000000001'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000001'
  s.version_id = nil
  s.event_type = 'draft_created'
  s.payload = { user_name: 'Yamada TARO' }
  s.created_at = 1.month.ago
end

Template::Mail::History.seed(:id) do |s|
  s.id = '10000000-0000-0000-0001-000000000002'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000001'
  s.version_id = nil
  s.event_type = 'draft_updated'
  s.payload = { user_name: 'Yamada TARO', changes: ['title', 'body'] }
  s.created_at = 1.day.ago
end

# Template 2 - Published: draft_created + published (v100)
Template::Mail::History.seed(:id) do |s|
  s.id = '10000000-0000-0000-0002-000000000001'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000002'
  s.version_id = nil
  s.event_type = 'draft_created'
  s.payload = { user_name: 'Yamada TARO' }
  s.created_at = 100.months.ago
end

Template::Mail::History.seed(:id) do |s|
  s.id = '10000000-0000-0000-0002-000000000100'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000002'
  s.version_id = '00000000-0000-0000-0002-000000000100'
  s.event_type = 'published'
  s.payload = { user_name: 'Yamada TARO', version: 100 }
  s.created_at = 1.month.ago
end

# Template 3 - Scheduled: draft_created + draft_updated + scheduled
Template::Mail::History.seed(:id) do |s|
  s.id = '10000000-0000-0000-0003-000000000001'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000003'
  s.version_id = nil
  s.event_type = 'draft_created'
  s.payload = { user_name: 'Yamada TARO' }
  s.created_at = 1.week.ago
end

Template::Mail::History.seed(:id) do |s|
  s.id = '10000000-0000-0000-0003-000000000002'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000003'
  s.version_id = nil
  s.event_type = 'draft_updated'
  s.payload = { user_name: 'Yamada TARO' }
  s.created_at = 2.days.ago
end

Template::Mail::History.seed(:id) do |s|
  s.id = '10000000-0000-0000-0003-000000000003'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000003'
  s.version_id = '00000000-0000-0000-0003-000000000013'
  s.event_type = 'scheduled'
  s.payload = { user_name: 'Yamada TARO', scheduled_at: 1.week.from_now, version: 13 }
  s.created_at = 1.day.ago
end

# Template 4 - Published: draft_created + published
Template::Mail::History.seed(:id) do |s|
  s.id = '10000000-0000-0000-0004-000000000001'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000004'
  s.version_id = nil
  s.event_type = 'draft_created'
  s.payload = { user_name: 'Yamada TARO' }
  s.created_at = 1.month.ago
end

Template::Mail::History.seed(:id) do |s|
  s.id = '10000000-0000-0000-0004-000000000002'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000004'
  s.version_id = '00000000-0000-0000-0004-000000000002'
  s.event_type = 'published'
  s.payload = { user_name: 'Yamada TARO', version: 2 }
  s.created_at = 2.weeks.ago
end

# Template 5 - Draft (empty): draft_created only
Template::Mail::History.seed(:id) do |s|
  s.id = '10000000-0000-0000-0005-000000000001'
  s.tenant_id = tenant_id
  s.template_id = '00000000-0000-0000-0000-000000000005'
  s.version_id = nil
  s.event_type = 'draft_created'
  s.payload = { user_name: 'Yamada TARO' }
  s.created_at = 3.days.ago
end
