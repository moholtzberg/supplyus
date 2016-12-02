class SalesRepsController < ApplicationController
  layout "admin"
  
  def index
    @sales_reps = User.joins(:roles).where("roles.name = ?", "Sales")
    unless params[:term].blank?
      @sales_reps = @sales_reps.lookup(params[:term]) if params[:term].present?
    end
    respond_to do |format|
      format.html
       msg = @sales_reps.map {|a|
        {
          :label => "#{a.first_name} #{a.last_name}",
          :value => "#{a.email}"
        }
      }
      format.json {render :json => msg}
      # format.json {render :json => @sales_reps.map(&:full_name)}
    end
  end
  
end