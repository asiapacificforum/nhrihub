module ApplicationHelpers
  def flash_message
    page.find("#message_block").text
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
end
