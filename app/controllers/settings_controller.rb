class SettingsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    @settings = Setting.all
  end
  
end