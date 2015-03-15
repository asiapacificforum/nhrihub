module ApplicationHelpers
  def flash_message
    page.find("#message_block")
  end

  def navigation_menu
    page.all("#nav li").map(&:text)
  end

  def page_heading
    page.find("h1").text
  end
end
