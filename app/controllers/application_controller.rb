class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :check_authorization
  before_action :miniprofiler
  
  
  if Rails.env.production?
    unless Rails.application.config.consider_all_requests_local
      rescue_from Exception, with: :render_500
      rescue_from ActionController::RoutingError, with: :render_404
      rescue_from ActionController::UnknownController, with: :render_404
      rescue_from AbstractController::ActionNotFound, with: :render_404
      rescue_from ActiveRecord::RecordNotFound, with: :render_404
    end
  end
  
  def check_authorization
    unless current_user.email.in?(["admin@247officesupply.com", "mjbustamante@247officesupply.com"])
      redirect_to "/"
    end
  end
  
  def render_404(exception)
    @not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'errors/not_found', layout: 'layouts/application', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def render_500(exception)
    logger.info exception.backtrace.join("\n")
    respond_to do |format|
      format.html { render template: 'errors/internal_server_error', layout: 'layouts/application', status: 500 }
      format.all { render nothing: true, status: 500}
    end
  end
  
  private

  def miniprofiler
    if current_user and current_user.email == "admin@247officesupply.com"
      Rack::MiniProfiler.authorize_request 
    end
  end
  
end
