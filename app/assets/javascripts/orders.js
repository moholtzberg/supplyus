var orders_table = null;
$(document).on('turbolinks:load', function() {
  if ($('#orders-table').length != 0) {
    var common_filters = [];
    $(function() {
      var possible_filters =  {
                                number: ['Equal to', 'Contains', 'Begins with', 'Ends with', 'Not equal to'],
                                account: ['Equal to', 'Contains', 'Begins with', 'Ends with', 'Not equal to'],
                                state: ['Equal to', 'Contains', 'Begins with', 'Ends with', 'Not equal to'],
                                submitted_at: ['Equal to', 'Greater than', 'Less than'],
                                sub_total: ['Equal to', 'Greater than', 'Less than']
                              }

      function FilterGroupRoot(children) {
        this.children = children ? children : [];
        this.condition = 'and'
      }

      FilterGroupRoot.prototype = {
        render: function() {
          var self = this;
          var template = '<div class="panel panel-default"> \
                            <div class="panel-heading">Filter Groups</div> \
                            <div class="panel-body"></div> \
                            <div class="panel-footer"> \
                              <button class="btn btn-default add-filter-group">Add Filter Group</button> \
                            </div> \
                          </div>';
          var $item = $(jQuery.parseHTML(template)[0]);
          $item.children('.panel-footer').find('.add-filter-group').click(function() {
            self.addItem(new FilterGroup(self));
          })
          $.each(self.children, function(i, child) {
            $item.children('.panel-body').append(child.render());
          })
          return $item
        },
        removeItem: function(item) {
          idx = this.children.indexOf(item);
          this.children.splice(idx, 1);
          $('#filterModal #modal-body').trigger('render');
        },
        addItem: function(item) {
          this.children.push(item);
          $('#filterModal #modal-body').trigger('render');
        },
        toJson: function() {
          var json = {};
          json.condition = this.condition;
          json.children = [];
          $.each(this.children, function(i, child) {
            json.children.push(child.toJson());
          })
          return json;
        }
      }

      function FilterGroup(parent, condition, children) {
        this.parent = parent;
        this.condition = condition ? condition : 'and';
        this.children = children ? children : [];
      }

      FilterGroup.prototype = {
        render: function() {
          var self = this;
          var template = '<div class="panel panel-default"> \
                            <div class="panel-heading">Match \
                              <select> \
                                <option value="and">All</option> \
                                <option value="or">Any</option> \
                              </select> \
                              conditions \
                              <button class="btn btn-default remove-filter-group">Remove</button> \
                            </div> \
                            <div class="panel-body"></div> \
                            <div class="panel-footer"> \
                              <button class="btn btn-default add-filter">Add Filter</button> \
                              <button class="btn btn-default add-filter-group">Add Filter Group</button> \
                            </div> \
                          </div>';
          var $item = $(jQuery.parseHTML(template)[0]);
          $item.children('.panel-heading').find('select').val(self.condition);
          $item.children('.panel-heading').find('.remove-filter-group').click(function() {
            self.parent.removeItem(self);
          })
          $item.children('.panel-footer').find('.add-filter-group').click(function() {
            self.addItem(new FilterGroup(self));
          })
          $item.children('.panel-footer').find('.add-filter').click(function() {
            self.addItem(new Filter(self));
          })
          $item.children('.panel-heading').find('select').change(function() {
            self.condition = $(this).val();
          })
          $.each(self.children, function(i, child) {
            $item.children('.panel-body').append(child.render());
          })
          return $item;
        },
        removeItem: function(item) {
          idx = this.children.indexOf(item);
          this.children.splice(idx, 1);
          $('#filterModal #modal-body').trigger('render');
        },
        addItem: function(item) {
          this.children.push(item);
          $('#filterModal #modal-body').trigger('render');
        },
        toJson: function() {
          var json = {};
          json.condition = this.condition;
          json.children = [];
          $.each(this.children, function(i, child) {
            json.children.push(child.toJson());
          })
          return json;
        }
      };

      function Filter(parent, column_name, filter, value) {
        this.parent = parent;
        this.column_name = column_name;
        this.filter = filter;
        this.value = value;
      }

      Filter.prototype = {
        render: function() {
          var self = this;
          var template = '<div class="form-inline"> \
                              <select class="column-name" class="form-control"> \
                                <option value></option> \
                                <option value="number">Number</option> \
                                <option value="account">Account</option> \
                                <option value="sub_total">Sub Total</option> \
                                <option value="submitted_at">Submitted At</option> \
                                <option value="state">State</option> \
                              </select> \
                              <select class="filter"> \
                              </select> \
                              <input class="value"/> \
                              <button class="btn btn-primary btn-sm remove-filter">Remove</button>\
                          </div>'
          var $item = $(jQuery.parseHTML(template)[0])
          $item.find('.remove-filter').click(function() {
            self.parent.removeItem(self);
          })
          self.setColumnName($item, self.column_name);
          self.setFilter($item, self.filter);
          self.setValue($item, self.value);
          $item.find(':input').change(function(e) {
            self.updateAttribute(e.target.className, $(e.target).val());
          })
          return $item;
        },
        setColumnName: function(dom_el, val) {
          dom_el.find(':input.column-name').val(val);
          this.column_name = val;
        },
        setFilter: function(dom_el, val) {
          $.each(possible_filters[this.column_name], function(index,value) {
            dom_el.find(':input.filter').append($('<option></option>')
                  .attr('value', value).text(value));
          });
          dom_el.find(':input.filter').val(val);
          this.filter = val;
        },
        setValue: function(dom_el, val) {
          dom_el.find(':input.value').val(val);
          if (this.column_name == 'submitted_at') {
            dom_el.find(':input.value').datepicker();
          } else {
            dom_el.find(':input.value').datepicker('destroy');
          }
          this.value = val;
        },
        updateAttribute: function(attribute, value) {
          switch(attribute) {
            case 'column-name':
              this.column_name = value;
              this.filter = '';
              this.value = '';
              break;
            case 'filter':
              this.filter = value;
              break;
            case 'value':
              this.value = value;
              break;
          }
          $('#filterModal #modal-body').trigger('render');
        },
        toJson: function() {
          var json = {};
          json.column_name = this.column_name;
          json.filter = this.filter;
          json.value = this.value;
          return json;
        }
      };

      var filter_group_root = new FilterGroupRoot();

      buildTree = function(json, parent) {
        if (json.column_name) {
          var filter = new Filter(parent, json.column_name, json.filter, json.value)
          parent.children.push(filter);
        } else {
          if (parent) {
            var filter_group = new FilterGroup(parent, json.condition)
            parent.children.push(filter_group)            
            $.each(json.children, function (index, value) {
              buildTree(value, filter_group)
            })
          } else {
            filter_group_root = new FilterGroupRoot();
            $.each(json.children, function (index, value) {
              buildTree(value, filter_group_root)
            })
          }
        } 
      }

      $('#filterModal #modal-body').on('render', function() {
        $('#filterModal #modal-body').html(filter_group_root.render());
      })

      $('button#update_filters').click(function(){
        common_filters = filter_group_root.toJson();
        $('#orders-table').trigger('filters-update')
        $('#filterModal').modal("toggle")
      })

      $('button#cancel_filters').click(function(){
        buildTree(common_filters);
        $('#filterModal #modal-body').trigger('render');
        $('#filterModal').modal("toggle")
      })

      $('#orders-table').on('filters-restore', function() {
        buildTree(common_filters);
        $('#filterModal #modal-body').trigger('render');
      })
    });
    orders_table = $('#orders-table').dataTable({
      "initComplete": function () {
        var self = this
        $('#orders-table').on('filters-update', function() {
          self.api().ajax.reload()
        })
      },
      "processing": true,
      "serverSide": true,
      "responsive": true,
      "stateSave": true,
      "sServerMethod": 'POST',
      "ajax": {
        "url": $('#orders-table').data('source'),
        "data": function ( d ) {
          d.filters = common_filters;
        }
      },
      stateSave: true,
      stateSaveCallback: function(settings,data) {
        data.filters = common_filters;
        key = 'DataTables_' + settings.sInstance + '_' + window.location.pathname
        localStorage.setItem( key, JSON.stringify(data) )
      },
      stateLoadCallback: function(settings) {
        key = 'DataTables_' + settings.sInstance + '_' + window.location.pathname
        data = JSON.parse( localStorage.getItem(key) );
        if (data && data.filters) { common_filters = data.filters; }
        $('#orders-table').trigger('filters-restore');
        return data
      },
      "pagingType": "full_numbers",
      "autoWidth": false,
      "sDom": 'rt<"row"<"col-sm-2"l><"col-sm-5"i><"col-sm-5"p>>',
      "columns": [
        {"data": "number", className: "all"},
        {"data": "account", className: "all"},
        {"data": "total", sortable: false, className: "all"},
        {"data": "sub_total", className: "all"},
        {"data": "shipped", sortable: false, className: "all"},
        {"data": "fulfilled", sortable: false, className: "all"},
        {"data": "balance_due", sortable: false, className: "all"},
        {"data": "submitted_at", className: "all"},
        {"data": "state", className: "all"},
        {"data": "dropdown", sortable: false, className: "all"}
      ]
    });
  }
});

$(document).on('turbolinks:before-cache', function() {
  if ($('#orders-table_wrapper').length != 0) {
    orders_table.fnDestroy();
    orders_table = null;
  }
})