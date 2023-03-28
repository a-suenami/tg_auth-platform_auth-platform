class Credentials < Thor
  include Thor::Actions

  # ----------------------------------------------------------------------------
  desc 'encrypt', 'Encrypt credentials in yaml files'
  # ----------------------------------------------------------------------------
  def encrypt
    say('Encrypt credentials...')
    run("bundle exec yaml_vault encrypt #{decrypted_settings_path} -o #{encrypted_settings_path}")
  end


  # ----------------------------------------------------------------------------
  desc 'decrypt', 'Decrypt credentials in yaml files'
  # ----------------------------------------------------------------------------
  def decrypt
    say('Decrypt credentials...')
    run("bundle exec yaml_vault decrypt #{encrypted_settings_path} -o #{decrypted_settings_path}")
  end


  private

  def decrypted_settings_path
    Rails.root.join('config', 'settings', "#{Rails.env}.secrets.yml")
  end

  def encrypted_settings_path
    Rails.root.join('config', 'settings', "#{Rails.env}.secrets.encrypted.yml")
  end
end
