$(function () {

 Recurring.flash = {

   setHtmlType: function (type) {
     // notice  - green (html_type = 'success' by default)
     // info    - blue
     // warning - yellow
     // alert, error - red

     var html_type = 'success';

     if ( $.inArray(type, ['alert', 'error']) !== -1 ) {
       html_type = 'danger';
     }

     if ( $.inArray(type, ['warning', 'info']) !== -1 ) {
       html_type = type;
     }

     return html_type;
   },

   flashHtml: function (type, msg) {
     var html_type = this.setHtmlType(type);
     return '<div class="alert fade in alert-' + html_type + '"><button type="button" class="close" data-dismiss="alert">×</button>' + msg + '</div>';
   },

   showMsg: function (type, msg) {
     var flash_wrapper = $('#flashes');
     flash_wrapper.html('');
     flash_wrapper.append(Recurring.flash.flashHtml(type, msg));
   }

 }

});