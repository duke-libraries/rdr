// Overrides hyrax/app/assets/javascripts/hyrax/ga_events.js
// in order to use gtag.js library instead of legacy ga.js

$(document).on('click', '#file_download', function(e) {
  gtag('event', 'Files', 'Downloaded', $(this).data('label'));
});
