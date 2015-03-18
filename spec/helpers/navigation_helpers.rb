require 'rspec/core/shared_context'

module NavigationHelpers
  extend RSpec::Core::SharedContext

  def toggle_navigation_dropdown(nav_text)
    page.find("li.dropdown>a", :text => nav_text).click
  end

  def select_dropdown_menu_item(menu_text)
    page.find("ul.dropdown-menu>li>a", :text => menu_text).click
  end
end
