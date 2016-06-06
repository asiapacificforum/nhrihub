module ApplicationHelpers
  def resize_browser_window
    if page.driver.browser.respond_to?(:manage)
      page.driver.browser.manage.window.resize_to(1400,800) # b/c selenium driver doesn't seem to click when target is not in the view
    end
  end

  def select_date(date,options)
    base = options[:from].to_s
    year_selector = base+"_1i"
    month_selector = base+"_2i"
    day_selector = base+"_3i"
    month,day,year = date.split(' ')
    select(year, :from => year_selector)
    select(month, :from => month_selector)
    select(day, :from => day_selector)
  end

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
