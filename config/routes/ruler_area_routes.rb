# require 'sidekiq/web'
# require 'sidekiq-scheduler/web'
# require 'sidekiq_unique_jobs/web'

Rails.application.routes.draw do
  namespace :ruler_area, path: :ruler do
    # ...
  end
end
