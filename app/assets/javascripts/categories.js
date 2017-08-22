var categories_table = null
$(document).on('turbolinks:load', function() {
  if ($('#categories-table').length != 0) {
    categories_table = $('#categories-table').dataTable({
      "processing": true,
      "serverSide": true,
      "responsive": true,
      "sServerMethod": 'POST', 
      "ajax": $('#categories-table').data('source'),
      "pagingType": "full_numbers",
      "autoWidth": false,
      "columns": [
        {"data": "id", className: "min-desktop"},
        {"data": "parent", className: "min-desktop", sortable: false},
        {"data": "name", className: "all"},
        {"data": "slug", className: "min-desktop"},
        {"data": "active", className: "min-desktop"},
        {"data": "show_in_menu", className: "min-desktop"},
        {"data": "menu_id", className: "min-desktop"},
        {"data": "children", className: "all", sortable: false},
        {"data": "items", className: "all", sortable: false},
        {"data": "dropdown", sortable: false, className: "all"}
      ]
    });
  };
});

$(document).on('turbolinks:before-cache', function() {
  if ($('#categories-table_wrapper').length != 0) {
    categories_table.fnDestroy();
    categories_table = null;
  }
})