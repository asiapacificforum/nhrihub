require 'rspec/core/shared_context'

module IccAdminSpecHelper
  extend RSpec::Core::SharedContext

  def new_doc_group_button
    page.find("#new_doc_group table button")
  end

  def delete_title(text)
    page.find(:xpath, ".//tr[contains(td,'#{text}')]").find('a').click
  end

  def resize_browser_window
    if page.driver.browser.respond_to?(:manage)
      page.driver.browser.manage.window.resize_to(1400,800) # b/c selenium driver doesn't seem to click when target is not in the view
    end
  end
end
