class ApplicationController < ActionController::Base
  if Rails.env.production?
    http_basic_authenticate_with name: ENV['AUTH_USERNAME'], password: ENV['AUTH_PASSWORD']
  end

  protect_from_forgery with: :exception
end
