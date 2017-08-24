class AssetsController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_asset, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  def index
    update_index
  end
  
  def new
    @asset = Asset.new
  end
  
  def create
    @asset = Asset.create(asset_params)
    update_index
    respond_to do |format|
      format.js
      format.json { render json: {
          error: (@asset.errors.full_messages.join(', ') if @asset.errors.any?),
          initialPreview: [@asset.attachment&.url],
          initialPreviewConfig: [@asset.to_fileinput_hash]
        }
      }
    end
  end
  
  def show
  end
  
  def edit
  end
    
  def update
    @asset.update_attributes(asset_params)
    update_index
  end

  def destroy
    @asset.destroy
    update_index
    respond_to do |format|
      format.js
      format.json { render json: {
          error: (@asset.errors.full_messages.join(', ') if @asset.errors.any?)
        }
      }
    end
  end
    
  private

  def set_asset
    @asset = Asset.find(params[:id])
  end

  def update_index
    @assets = Asset.order(sort_column + " " + sort_direction)
    unless params[:term].blank?
      @assets = @assets.lookup(params[:term]) if params[:term].present?
    end
    @assets = @assets.paginate(:page => params[:page], :per_page => 25)
  end

  def asset_params
    prms = params.require(:asset).permit(:attachment, :item_number, :position, :alt, :item_id)
    prms[:alt] = prms[:attachment]&.original_filename&.gsub(/(.*)\.\w*$/, '\1') if prms[:attachment] && (!prms[:alt] || prms[:alt].blank?)
    prms[:item_id] = params[:item_id] if params[:item_id]
    prms
  end

  def sort_column
    related_columns = Asset.reflect_on_all_associations(:belongs_to).map {|a| a.klass.column_names.map {|col| "#{a.klass.table_name}.#{col}"}}
    columns = Asset.column_names.map {|a| "assets.#{a}" }
    columns.push(related_columns).flatten!.uniq!
    columns.include?(params[:sort]) ? params[:sort] : "assets.attachment_file_name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end