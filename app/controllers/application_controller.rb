# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def health_check
    head :ok
  end
end
