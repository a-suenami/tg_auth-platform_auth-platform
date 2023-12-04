custom_mapping_path = "#{Rails.root}/config/prefecture.yml"

JpPrefecture.setup do |config|
  config.mapping_data = YAML.load_file(custom_mapping_path)
end
