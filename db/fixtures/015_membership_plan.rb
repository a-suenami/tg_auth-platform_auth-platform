# seed membership plans
Membership::Plan.seed do |s|
  s.id = '3eb43056-cf30-43cd-82e7-00a754c68799'
  s.tenant_id = 'sample'
  s.name = '段階的プラン ベーシック 月額'
  s.recurrence = true
  s.recurring_interval_count = 1
  s.recurring_interval_unit = 'month'
  s.amount = 500
  s.is_active = true
  s.enabled_at = nil
  s.disabled_at = nil
  s.trial_period_days = 0
  s.billing_anchor = 'by_start_day'
  s.anchor_day_of_month = nil
  s.position = 0
end

Membership::Plan.seed do |s|
  s.id = '8f556de9-52dc-48d2-b46d-cab0f762411a'
  s.tenant_id = 'sample'
  s.name = '段階的プラン ベーシック 年額'
  s.recurrence = true
  s.recurring_interval_count = 1
  s.recurring_interval_unit = 'year'
  s.amount = 6000
  s.is_active = true
  s.enabled_at = nil
  s.disabled_at = nil
  s.trial_period_days = 0
  s.billing_anchor = 'by_start_day'
  s.anchor_day_of_month = nil
  s.position = 0
end

Membership::Plan.seed do |s|
  s.id = '0f29cb57-43f1-45f2-a68f-87b51ea6d60f'
  s.tenant_id = 'sample'
  s.name = '段階的プラン プレミアム 月額'
  s.recurrence = true
  s.recurring_interval_count = 1
  s.recurring_interval_unit = 'month'
  s.amount = 1000
  s.is_active = true
  s.enabled_at = nil
  s.disabled_at = nil
  s.trial_period_days = 0
  s.billing_anchor = 'by_start_day'
  s.anchor_day_of_month = nil
  s.position = 0
end

Membership::Plan.seed do |s|
  s.id = '9c074597-5ef2-450c-a7f4-38c3146cdf00'
  s.tenant_id = 'sample'
  s.name = '段階的プラン プレミアム 年額'
  s.recurrence = true
  s.recurring_interval_count = 1
  s.recurring_interval_unit = 'year'
  s.amount = 12000
  s.is_active = true
  s.enabled_at = nil
  s.disabled_at = nil
  s.trial_period_days = 0
  s.billing_anchor = 'by_start_day'
  s.anchor_day_of_month = nil
  s.position = 0
end

Membership::Plan.seed do |s|
  s.id = '68a09b39-4667-4c76-898f-c46fb907a091'
  s.tenant_id = 'sample'
  s.name = '段階的プラン プラチナ 月額'
  s.recurrence = true
  s.recurring_interval_count = 1
  s.recurring_interval_unit = 'month'
  s.amount = 1200
  s.is_active = true
  s.enabled_at = nil
  s.disabled_at = nil
  s.trial_period_days = 0
  s.billing_anchor = 'by_start_day'
  s.anchor_day_of_month = nil
  s.position = 0
end

Membership::Plan.seed do |s|
  s.id = 'aa7e16f2-ed85-40b0-99aa-6ca72bd7f85c'
  s.tenant_id = 'sample'
  s.name = '段階的プラン プラチナ年額'
  s.recurrence = true
  s.recurring_interval_count = 1
  s.recurring_interval_unit = 'year'
  s.amount = 14400
  s.is_active = true
  s.enabled_at = nil
  s.disabled_at = nil
  s.trial_period_days = 0
  s.billing_anchor = 'by_start_day'
  s.anchor_day_of_month = nil
  s.position = 0
end

Membership::Plan.seed do |s|
  s.id = 'fc149b9a-6edd-477e-884d-8bed861516bc'
  s.tenant_id = 'sample'
  s.name = '段階的プラン ベーシック 日次(テスト用)'
  s.recurrence = true
  s.recurring_interval_count = 1
  s.recurring_interval_unit = 'day'
  s.amount = 100
  s.is_active = true
  s.enabled_at = nil
  s.disabled_at = nil
  s.trial_period_days = 0
  s.billing_anchor = 'by_start_day'
  s.anchor_day_of_month = nil
  s.position = 0
end

Membership::Plan.seed do |s|
  s.id = '825656fc-17fb-4481-a35d-a93b80055d1b'
  s.tenant_id = 'sample'
  s.name = '段階的プラン プレミアム 日次(テスト用)'
  s.recurrence = true
  s.recurring_interval_count = 1
  s.recurring_interval_unit = 'day'
  s.amount = 200
  s.is_active = true
  s.enabled_at = nil
  s.disabled_at = nil
  s.trial_period_days = 0
  s.billing_anchor = 'by_start_day'
  s.anchor_day_of_month = nil
  s.position = 0
end

Membership::Plan.seed do |s|
  s.id = 'eb3651b5-334e-4694-bf4b-a7b1ca7ce7a2'
  s.tenant_id = 'sample'
  s.name = 'メンバーシップABセット'
  s.recurrence = true
  s.recurring_interval_count = 1
  s.recurring_interval_unit = 'month'
  s.amount = 400
  s.is_active = true
  s.enabled_at = nil
  s.disabled_at = nil
  s.trial_period_days = 0
  s.billing_anchor = 'by_start_day'
  s.anchor_day_of_month = nil
  s.position = 0
end

Membership::Plan.seed do |s|
  s.id = '0d469f6d-4483-4dd4-9d2e-e8c9dfb7c75e'
  s.tenant_id = 'sample'
  s.name = 'メンバーシップABセット 年額'
  s.recurrence = true
  s.recurring_interval_count = 1
  s.recurring_interval_unit = 'year'
  s.amount = 4000
  s.is_active = true
  s.enabled_at = nil
  s.disabled_at = nil
  s.trial_period_days = 0
  s.billing_anchor = 'by_start_day'
  s.anchor_day_of_month = nil
  s.position = 0
end
