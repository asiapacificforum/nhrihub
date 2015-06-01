module ApplicationHelpers
  def flash_message
    page.find(".message_block").text
  end

  def navigation_menu
    page.all(".nav.navbar-nav li a").map(&:text)
  end

  def page_heading
    page.find("h1").text
  end

  def page_title
    page.driver.title
  end

  def page!
    save_and_open_page
  end

  # Saves page to place specfied at in configuration.
  # NOTE: you must pass js: true for the feature definition (or else you'll see that render doesn't exist!)
  # call force = true, or set ENV[RENDER_SCREENSHOTS] == 'YES'
  def render_page(name, force = false)
    if force || (ENV['RENDER_SCREENSHOTS'] == 'YES')
      path = File.join Rails.application.config.integration_test_render_dir, "#{name}.png"
      page.driver.render(path)
    end
  end
end
