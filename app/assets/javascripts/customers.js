var customers_table = null
$(document).on('turbolinks:load', function() {
  customers_table = $('#customers-table').dataTable({
    "processing": true,
    "serverSide": true,
    "responsive": true,
    "sServerMethod": 'POST', 
    "ajax": $('#customers-table').data('source'),
    "pagingType": "full_numbers",
    "autoWidth": false,
    "columns": [
      {"data": "id", className: "min-desktop"},
      {"data": "group", className: "all"},
      {"data": "name", className: "all"},
      {"data": "address_1", className: "min-desktop"},
      {"data": "city", className: "min-desktop"},
      {"data": "state", className: "min-desktop"},
      {"data": "zip", className: "min-desktop"},
      {"data": "phone", className: "min-desktop"},
      {"data": "dropdown", sortable: false, className: "all"}
    ]
  });
});

$(document).on('turbolinks:before-cache', function() {
  if ($('#customers-table_wrapper').length != 0) {
    customers_table.fnDestroy();
  }
})