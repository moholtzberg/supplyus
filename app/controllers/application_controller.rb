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

  # CanCanCan: Permission error handler
  rescue_from CanCan::AccessDenied do |exception|
    # if you want change msg you should know about checks in js (app/assets/javascripts/ajax_setup.js),
    #   where responseText compares with 'You need permission to perform this action.' If it's ok we show flash message from js about permission error.
    msg = 'You need permission to perform this action.'
    respond_to do |format|
      format.html {render text: msg}
      format.json {render :json => {permission_error: msg}}
      format.js   {render :json => {permission_error: msg}}
    end

  end
  
  def check_authorization
    # it seems this is bug: when user signed in we can check his email (current_user.email), if not current_user === nil and it will fall anyway. Maybe it will be better hide sign up link for unauthorized users.
    # unless current_user.email.in?(["admin@247officesupply.com", "mjbustamante@247officesupply.com"])
    #   redirect_to "/"
    # end

    if !current_user || !current_user.roles.any? || current_user.has_role?(:customer) || current_user.has_role?(:public)
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
    if current_user and current_user.has_role?(:super_admin)
      Rack::MiniProfiler.authorize_request 
    end
  end
  
end
