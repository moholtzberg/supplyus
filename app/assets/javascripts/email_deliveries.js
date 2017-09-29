var email_devlieries_table = null
$(document).on('turbolinks:load', function() {
  if ($('#email-deliveries-table').length != 0) {
    email_devlieries_table = $('#email-deliveries-table').dataTable({
      "processing": true,
      "serverSide": true,
      "responsive": true,
      "sServerMethod": 'POST', 
      "ajax": $('#email-deliveries-table').data('source'),
      "pagingType": "full_numbers",
      "autoWidth": false,
      "columns": [
        {"data": "id", className: "min-desktop"},
        {"data": "addressable_type", className: "all"},
        {"data": "addressable_id", className: "all"},
        {"data": "to_email", className: "all"},
        {"data": "eventable_type", className: "all"},
        {"data": "eventable_id", className: "all"},
        {"data": "failed_at", className: "min-desktop"},
        {"data": "delivered_at", className: "min-desktop"},
        {"data": "opened_at", className: "min-desktop"},
        {"data": "dropdown", sortable: false, className: "all"}
      ]
    });
  };
});

$(document).on('turbolinks:before-cache', function() {
  if ($('#email-deliveries-table_wrapper').length != 0) {
    email_devlieries_table.fnDestroy();
    email_devlieries_table = null;
  }
})