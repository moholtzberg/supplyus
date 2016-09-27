class SettingsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    authorize! :read, Setting
    @settings = Setting.all
  end
  
  def new
    authorize! :create, Setting
    @setting = Setting.new
  end
  
end