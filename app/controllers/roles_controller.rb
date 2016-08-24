class RolesController < ApplicationController
  layout "admin"

  before_action :find_role, only: [:edit, :update, :destroy]

  def index
    authorize! :read, Role
    @roles = Role.all
    respond_to do |format|
      format.html
      format.json {render :json => @roles.map(&:name)}
    end
  end

  def show
    authorize! :read, Role
  end

  def new
    authorize! :create, Role
    @role = Role.new
  end

  def create
    authorize! :create, Role
    @role = Role.new(role_params)

    if @role.save
      redirect_to edit_role_path(@role), notice: "Role was created."
    else
      flash[:alert] = "Role wasn't created."
      render :new
    end
  end
  
  def edit
    authorize! :update, Role
    @permission = Permission.new
  end
  
  def update
    authorize! :update, Role
    if @role.update(role_params)
      # Destroy first marked permissions (params[:destroy_ids] - check to destroy)
      destroy_ids = params[:destroy_ids].reject(&:blank?).map(&:to_i).uniq
      Permission.where(id: destroy_ids).destroy_all

      permissions = permissions_params

      errors = []
      permissions_changes = []
      permissions.each do |permission|
        permission = permission[1]

        next unless permission[:mdl_name].present?

        permission_exists = @role.permissions.find_by_mdl_name(permission[:mdl_name])

        # update permission
        if permission_exists
          permission_exists.update(permission.symbolize_keys)
          permissions_changes << 1
        else
          # create permission
          new_permission = @role.permissions.new(permission.symbolize_keys)

          if new_permission.save
            permissions_changes << 1
            next
          else
            errors << "Permission wasn't created"
          end

        end
      end if permissions.present?

      if errors.any?
        flash[:error] = "Some permissions weren't created, check it!"
        @permission = Permission.new
        render :edit
      else
        redirect_to edit_role_path(@role), notice: ((permissions_changes.any? || destroy_ids.present?) ? "Role permissions were saved." :  "Nothing was changed.")
      end

    else
      flash[:error] = "Role wasn't updated."
      @permission = Permission.new
      render :edit
    end
  end

  def destroy
    authorize! :destroy, Role
    if @role.destroy
      redirect_to roles_path, notice: 'Role was destroyed.'
    else
      redirect_to roles_path, error: "Role wasn't destroyed."
    end
  end

  def add_role_to_user
    authorize! :update, Role
    user, role = set_user_and_role
    add_or_remove_user_role(user, role, 'add')
  end

  def remove_role_from_user
    authorize! :update, Role
    user, role = set_user_and_role
    add_or_remove_user_role(user, role, 'remove')
  end

  def set_user_and_role
    [User.find_by_id(params[:user_id]), Role.find_by_id(params[:role_id])]
  end

  def add_or_remove_user_role(user, role, action_type)
    if role && user
      # "add_role" - add role in users_roles table and add role in Roles table (but we usually have role name in Roles table)
      # "add_role" will work without role duplicating in table "Roles" if it exists
      # "remove_role" -  just remove string from users_roles table. This is not Rolify method (redefined in User model)
      user.public_send("#{action_type}_role", role.name)
      render json: {success: true}
    else
      render json: {success: false, error: "Can't find user or role"}
    end
  end

  private

  def role_params
    params.require(:role).permit(:name)
  end

  def permissions_params
    params[:permission]
  end

  def find_role
    @role = Role.find(params[:id])
  end
  
end