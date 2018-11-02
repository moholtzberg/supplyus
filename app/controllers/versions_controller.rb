class VersionsController < ApplicationController
  layout 'admin'
  respond_to :html, :json

  def datatables
    authorize! :read, PaperTrail::Version
    render json: VersionDatatable.new(view_context)
  end

  def index
    authorize! :read, PaperTrail::Version
  end

  def show
    @version = PaperTrail::Version.find(params[:id])
  end
end
