require 'rspec/core/shared_context'

module ComplaintAdminSpecHelpers
  def new_siu_complaint_basis_button
    page.find('#new_siu_basis button')
  end

  def new_gg_complaint_basis_button
    page.find('#new_gg_basis button')
  end

  def flash_message
    page.find(".message_block").text
  end

  def delete_complaint_basis(text)
    page.find(:xpath, ".//tr[contains(td,'#{text}')]//a")
  end
end
