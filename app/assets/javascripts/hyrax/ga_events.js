// Overrides hyrax/app/assets/javascripts/hyrax/ga_events.js
// in order to use gtag.js library instead of legacy ga.js

// Documentation: https://developers.google.com/analytics/devguides/collection/gtagjs/events

// Track download link clicks whether on work or fileset show page
$(document).on('click', '[id^="file_download"]', function(e) {
  gtag('event', 'Downloaded', {
    'event_category': 'Files',
    'event_label': $(this).data('label')
  });
});

// User clicked Export Files from a work show page
$(document).on('click', '#bulk_export_begin', function(e) {
  gtag('event', 'Bulk Export Initiated', {
    'event_category': 'Bulk Export',
    'event_label': $(this).data('label')
  });
});

// User clicked the final confirming "Yes, Export" button in
// the bulk export process
$(document).on('click', '#bulk_export_confirm', function(e) {
  gtag('event', 'Bulk Export Confirmed', {
    'event_category': 'Bulk Export',
    'event_label': $(this).data('label')
  });
});
