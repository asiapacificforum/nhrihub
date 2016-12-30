require 'rspec/core/shared_context'

module ComplaintAdminSpecHelpers

  def new_siu_complaint_subarea_button
    page.find('#new_siu_subarea button')
  end

  def new_gg_complaint_subarea_button
    page.find('#new_good_governance_subarea button')
  end

  def new_corporate_services_complaint_subarea_button
    page.find('#new_corporate_services_subarea button')
  end

  def delete_complaint_subarea(text)
    page.find(:xpath, ".//tr[contains(td,'#{text}')]//a")
  end
end
