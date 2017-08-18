var items_table = null
$(document).on('turbolinks:load', function() {
  items_table = $('#items-table').dataTable({
    "processing": true,
    "serverSide": true,
    "responsive": true,
    "sServerMethod": 'POST', 
    "ajax": $('#items-table').data('source'),
    "pagingType": "full_numbers",
    "autoWidth": false,
    "columns": [
      {"data": "id", className: "min-desktop"},
      {"data": "number", className: "all"},
      {"data": "name", className: "all"},
      {"data": "default_price", className: "all"},
      {"data": "times_sold", sortable: false, className: "min-desktop"},
      {"data": "dropdown", sortable: false, className: "all"}
    ]
  });
});

$(document).on('turbolinks:before-cache', function() {
  if ($('#items-table_wrapper').length != 0) {
    items_table.fnDestroy();
  }
})