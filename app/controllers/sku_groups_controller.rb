class SkuGroupsController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_sku_group, only: [:show, :destroy, :edit, :update]
  load_resource except: [:new, :create]
  authorize_resource class: 'SkuGroup'

  def index
    @sku_groups = update_index
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @sku_groups.map(&:to_select2) }
    end
  end

  def new
    @sku_group_form = SkuGroupForm.new
  end

  def create
    @sku_group_form = SkuGroupForm.new(sku_group_params)
    @sku_group_form.save
    @sku_groups = update_index
  end

  def show
    @items = @sku_group.items.paginate(page: params[:page], per_page: 25)
  end

  def edit
    @sku_group_form = SkuGroupForm.new(id: params[:id])
  end

  def update
    @sku_group_form = SkuGroupForm.new(sku_group_params.merge(id: params[:id]))
    @sku_group_form.save
    @sku_groups = update_index
  end

  def destroy
    @sku_group.destroy!
    @sku_groups = update_index
  end

  private

  def set_sku_group
    @sku_group = SkuGroup.find(params[:id])
  end

  def update_index
    SkuGroup.order(sort_column + ' ' + sort_direction)
            .lookup(params[:term])
            .paginate(page: params[:page], per_page: 25)
  end

  def sku_group_params
    params.require(:sku_group_form).permit(:name, :image_attachment, :image_alt)
  end

  def sort_column
    SkuGroup.column_names.include?(params[:sort]) ? params[:sort] : 'name'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
