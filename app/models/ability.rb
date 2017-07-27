class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # If we use "read" -> we give access to "index" & "show"
    alias_action :read, :create, :update, :destroy, :to => :crud
    # Example with alias -> can :crud, User

    # For specific action in controller we need to write in controller action:
    # authorize! :read, Item or authorize! :destroy, User etc


    # SUPER ADMIN HAS ALL PERMISSIONS BY DEFAULT!

    if user.has_role?(:super_admin)
      can :crud, :all
    else

      # Set permissions dynamically depend on roles and their permissions
      user.roles.each do |role|
        role.permissions.each do |permission|
          mdl_class = permission.mdl_name.camelize.constantize

          # If we have Vendor we have specific case -> Vendor class inherits from Account: "class Vendor < Account end"
          # If user has permission for Account - this user automatically has permission for Vendor
          # For splitted permissions between Vendor and Account we will use alias for vendor rights in checks (:vendor as string not as class (Vendor))
          # It is here like this: "can :read, :vendor" (not "can :read, Vendor")
          # and in VendorsController: "authorize! :read, :vendor" (not "authorize! :read, Vendor")

          # For this exception: if (permission.mdl_name == 'vendor') we will use "permission.mdl_name.to_sym" as "class_or_alias"
          class_or_alias = (permission.mdl_name == 'vendor') ? permission.mdl_name.to_sym : mdl_class

          # It generates rules
          [:create, :read, :update, :destroy].each do |action_name|
            # Result example:
            # "can :read, Item"
            # ... etc
            can action_name, class_or_alias if permission.public_send("can_#{action_name}")
          end
        end
      end

      if user.has_role?(:customer)
        can :crud, Address, account_id: user.account_id
        can :crud, CreditCard, account_payment_service_id: user.account.account_payment_services.ids
        can :crud, ItemList, user_id: user.id
        can :crud, ItemItemList, item_list_id: user.item_lists.ids
        can :create, Payment, account_id: user.account_id, credit_card_id: user.account.account_payment_services.map(&:credit_cards).map(&:ids).flatten.uniq
        can [:create, :read, :update], Subscription
        can :destroy, Subscription do |subscription|
          subscription.account_id == user.account_id
          subscription.orders.is_complete.size >= 3
        end
      end
    end


    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
