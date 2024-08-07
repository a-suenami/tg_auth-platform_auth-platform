# ==============================================================================
# config - initializers - 000 monkey patches
# ==============================================================================
Dir[Rails.root.join('lib/monkey_patches/**/*.rb')].each do |file|
  require file
end
