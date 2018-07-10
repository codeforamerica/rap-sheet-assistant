class ApplicationController < ActionController::Base
  before_action :set_raven_context

  if Rails.env.production?
    http_basic_authenticate_with name: ENV['AUTH_USERNAME'], password: ENV['AUTH_PASSWORD']
  end

  protect_from_forgery with: :exception

  def not_found
    render file: 'public/404.html', status: :not_found, layout: false
  end

  private

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
