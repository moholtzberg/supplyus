var versions_table = null
$(document).on('turbolinks:load', function() {
  if ($('#versions-table').length != 0) {
    versions_table = $('#versions-table').dataTable({
      "processing": true,
      "serverSide": true,
      "responsive": true,
      "sServerMethod": 'POST', 
      "ajax": $('#versions-table').data('source'),
      "pagingType": "full_numbers",
      "autoWidth": false,
      "stateSave": true,
      "columns": [
        {"data": "item_type", className: "all"},
        {"data": "item_id", className: "all"},
        {"data": "event", className: "all"},
        {"data": "whodunnit", className: "all"},
        {"data": "created_at", className: "all"},
        {"data": "dropdown", sortable: false, className: "all"}
      ]
    });
  };
});

$(document).on('turbolinks:before-cache', function() {
  if ($('#versions-table_wrapper').length != 0) {
    versions_table.fnDestroy();
    versions_table = null;
  }
})