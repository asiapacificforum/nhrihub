/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Ractive from 'ractive'

//= require 'in_page_edit'
//= require 'ractive_validator'
//= require 'file_input_decorator'
//= require 'progress_bar'
//= require 'ractive_local_methods'
//= require 'string'
//= require 'jquery_datepicker'
//= require 'filter_criteria_datepicker'
//= require 'confirm_delete_modal'
//= require 'attached_documents'
//= require 'communication'
//= require 'notable'
//= require 'remindable'

window.complaints_page_data = () =>
  ({
    complaints : source_complaints_data,
    all_mandates : source_all_mandates,
    complaint_bases : source_complaint_bases,
    all_agencies : source_all_agencies,
    all_agencies_in_sixes : source_all_agencies_in_sixes,
    all_users : source_all_users,
    filter_criteria : source_filter_criteria,
    all_good_governance_complaint_bases : source_all_good_governance_complaint_bases,
    all_human_rights_complaint_bases : source_all_human_rights_complaint_bases,
    all_special_investigations_unit_complaint_bases : source_all_special_investigations_unit_complaint_bases,
    all_staff : source_all_staff,
    permitted_filetypes : source_permitted_filetypes,
    maximum_filesize : source_maximum_filesize,
    communication_permitted_filetypes : source_communication_permitted_filetypes,
    communication_maximum_filesize : source_communication_maximum_filesize,
    statuses : source_statuses,
    next_case_reference : source_next_case_reference
  })
;

import complaints_options from '../complaints_page.ractive.pug'
import filter_criteria_datepicker from '../../../../../../app/assets/javascripts/filter_criteria_datepicker'

window.start_page = () => window.complaints = new Ractive(complaints_options);

Ractive.prototype.local = gmt_date=> $.datepicker.formatDate("M d, yy", new Date(gmt_date));

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
