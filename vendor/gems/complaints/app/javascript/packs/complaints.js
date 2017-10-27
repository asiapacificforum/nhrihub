/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

window.complaints_page_data = () =>
  ({
    complaints : source_complaints_data,
    filter_criteria : source_filter_criteria,
    next_case_reference : source_next_case_reference
  })
;

import complaints_options from '../complaints_page.ractive.pug'
var filter_criteria_datepicker = require("exports-loader?filter_criteria_datepicker!filter_criteria_datepicker")

_.extend(Ractive.defaults.data, {
  all_users : source_all_users,
  all_mandates : source_all_mandates,
  complaint_bases : source_complaint_bases,
  all_agencies : source_all_agencies,
  all_agencies_in_sixes : _.chain(source_all_agencies).groupBy(function(el,i){return Math.floor(i/6)}).toArray().value(),
  all_good_governance_complaint_bases : source_all_good_governance_complaint_bases,
  all_human_rights_complaint_bases : source_all_human_rights_complaint_bases,
  all_special_investigations_unit_complaint_bases : source_all_special_investigations_unit_complaint_bases,
  all_staff : source_all_staff,
  permitted_filetypes : source_permitted_filetypes,
  maximum_filesize : source_maximum_filesize,
  communication_permitted_filetypes : source_communication_permitted_filetypes,
  communication_maximum_filesize : source_communication_maximum_filesize,
  statuses : source_statuses,
  local : function(gmt_date){ return $.datepicker.formatDate("M d, yy", new Date(gmt_date)); }
})

window.start_page = () => window.complaints = new Ractive(complaints_options);

$(function() {
  start_page();
  filter_criteria_datepicker.start(complaints);
  // so that a state object is present when returnng to the initial state with the back button
  // this is so we can discriminate returning to the page from page load
  return history.replaceState({bish:"bosh"},"bash",window.location);
});

window.onpopstate = function(event){
  if (event.state) { // to ensure that it doesn't trigger on page load, it's a problem with phantomjs but not with chrome
    return window.complaints.findComponent('filterControls').set_filter_from_query_string();
  }
};
