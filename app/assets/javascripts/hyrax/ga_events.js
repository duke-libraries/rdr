// Overrides hyrax/app/assets/javascripts/hyrax/ga_events.js
// in order to use gtag.js library instead of legacy ga.js

// Documentation: https://developers.google.com/analytics/devguides/collection/gtagjs/events

$(document).on('click', '#file_download', function(e) {
  gtag('event', 'Downloaded', {
    'event_category': 'Files',
    'event_label': $(this).data('label')
  });
});
