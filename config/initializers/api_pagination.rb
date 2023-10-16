ApiPagination.configure do |config|
  config.paginator = :pagy
  config.page_param = :page
  config.per_page_param = :per_page
  config.include_total = true
  Pagy::DEFAULT[:max_per_page] = 50
end
