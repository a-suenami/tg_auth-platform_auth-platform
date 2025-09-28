# ==============================================================================
# config - initializers - 000 monkey patches
# ==============================================================================
Rails.root.glob('lib/monkey_patches/**/*.rb').each do |file|
  require file
end
