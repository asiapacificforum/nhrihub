require 'rspec/core/shared_context'

module TermsOfReferenceSpecHelper
  def first_edit_icon
    page.all('.terms_of_reference_version .icon .no_edit i.fa-pencil-square-o').first
  end

  def edit_save_icon
    page.all('.terms_of_reference_version .icon .edit i.fa-check').first
  end

  def first_delete_icon
    page.all('.terms_of_reference_version .icon i.fa-trash-o').first
  end

  def click_the_download_icon
    page.all('.terms_of_reference_version .icon i.fa-cloud-download').first.click
  end
end
