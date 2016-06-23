$(function () {
  Recurring.roles = {

    // Change role permissions

    hidePermissionBlock: function (perm_block) {
      perm_block.hide();
      var inputs = perm_block.find('input');

      inputs.each(function () {
        $(this)
        .attr('checked', false)
        .attr('name', $(this).attr('name').replace(/[0-9]+/g, "100"))
        .attr('name', $(this).attr('name').replace('permission', "template"));

        if (typeof $(this).attr('id') !== 'undefined') {
          $(this).attr('id', $(this).attr('id').replace(/[0-9]+/g, "100"));
        }
      });

      // template with fake inputs names
      var select = perm_block.find('select').first();
      select
        .val('')
        .attr('id', select.attr('id').replace(/[0-9]+/g, '100'))
        .attr('name', select.attr('name').replace(/[0-9]+/g, "100"))
        .attr('name', select.attr('name').replace('permission', "template"));

      var labels = perm_block.find('label');
      labels.each(function () {
        $(this)
          .val('')
          .attr('for', $(this).attr('for').replace(/[0-9]+/g, "100"));
      });

      perm_block.find('.delete-permisson').first()
        .attr('data-id', null)
        .data('id', null);
    // end template

    },

    deletePermissionBlock: function (elem) {
      console.log('init deletePermission');
      var id = elem.data('id');

      // add id to destroy_ids if id exists
      if (id) {
        var ids_input = $('.destroy_ids').last();
        ids_input.clone().val(id).insertAfter(ids_input);
      }

      // hide permission block if it is last block on page
      var perm_block =  elem.closest('.permission_block');
      if ($('.permission_block').length == 1) {
        Recurring.roles.hidePermissionBlock(perm_block);
      } else {
        // delete permission block from page
        elem.closest('.permission_block').remove();
      }

    },

    addPermissionBlock: function () {
      var last_block = $('.permission_block').last();
      var index = last_block.find('input').last().attr('name').replace(/\D/g, "");
      var next_index;

      if ($('.permission_block:visible').length == 0) {
        next_index = 0;
      } else {
        next_index = parseInt(index)+1;
      }

      // clone and add real new index and right inputs names
      var cloned = last_block.clone();
      cloned.find('input').each(function () {
        $(this)
          .attr('name', $(this).attr('name').replace(/[0-9]+/g, next_index))
          .attr('name', $(this).attr('name').replace('template', 'permission'))
          .attr('checked', false);

        if (typeof $(this).attr('id') !== 'undefined') {
          $(this).attr('id', $(this).attr('id').replace(/[0-9]+/g, next_index));
        }
      });

      var select = cloned.find('select').first();
      select
        .val('')
        .attr('name', select.attr('name').replace(/[0-9]+/g, next_index))
        .attr('name', select.attr('name').replace('template', 'permission'))
        .attr('id', select.attr('id').replace(/[0-9]+/g, next_index));

      var labels = cloned.find('label');
      labels.each(function () {
        $(this)
        .val('')
        .attr('for', $(this).attr('for').replace(/[0-9]+/g, next_index));
      });


      cloned.appendTo($('#permissions_block')).show();
      // clone end
    },

    // Change user roles
    cloneSelect: function (icon) {
      // clone role select and make it enabled
      var role_wrapper = icon.closest('.role_block');
      var cloned = role_wrapper.clone();
      cloned.find('select').val('').removeClass('disabled').attr('disabled', false);
      cloned.insertAfter(role_wrapper);
    },

    callBackAfterAdd: function (role_wrapper) {
      role_wrapper.find('select').addClass('disabled').attr('disabled', 'disabled');
      Recurring.flash.showMsg('notice', "Role was added.");
    },

    addRole: function (select) {
      var role_wrapper = select.closest('.role_block');

      $.ajax({
        url: select.data('path'),
        type: 'POST',
        data: { user_id: select.data('user-id'), role_id: select.val() },
        success: function (data) {
          if (data.success) {
            Recurring.roles.callBackAfterAdd(role_wrapper);
          } else {
            console.log(data.error);
            Recurring.flash.showMsg('error', "Roles: Something went wrong.");
          }
        },
        error: function () {
          Recurring.flash.showMsg('error', "Roles: Something went wrong.");
        }
      });
    },

    callBackAfterRemove: function (role_wrapper) {
      var selects = role_wrapper.closest('td').find('select');

      if (selects.length == 1) {
        // clear select if it is only one
        selects.first().val('');
        role_wrapper.find('select').removeClass('disabled').attr('disabled', false)
      } else {
        // or delete role_block
        role_wrapper.remove();
      }
    },

    removeRole: function (link) {

      var role_wrapper = link.closest('.role_block');
      var role_select = role_wrapper.find('select');
      var role_id = role_select.val();
      var user_id = link.data('user-id');

      if (role_id !== '') {

        $.ajax({
          url: link.data('path'),
          type: 'DELETE',
          data: { user_id: user_id, role_id: role_id },
          success: function (data) {
            if (data.success) {
              Recurring.flash.showMsg('info', "Role was deleted.");
              Recurring.roles.callBackAfterRemove(role_wrapper);
            } else {
              console.log(data.error);
              Recurring.flash.showMsg('error', "Roles: Something went wrong.");
            }
          },
          error: function () {
            Recurring.flash.showMsg('error', "Roles: Something went wrong.");
          }
        });

      } else {
        Recurring.roles.callBackAfterRemove(role_wrapper);
      }

    },

    bindEvents: function () {
      // you can set events handler here
    },

    init: function () {
      this.bindEvents();
    }
  };

  Recurring.roles.init();
});