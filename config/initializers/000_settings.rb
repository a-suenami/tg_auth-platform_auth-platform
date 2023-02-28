Settings.add_source! Rails.root.join('config', 'settings', "#{Rails.env}.secrets.yml").to_s
Settings.reload!
