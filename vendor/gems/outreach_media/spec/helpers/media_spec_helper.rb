require 'rspec/core/shared_context'

module MediaSpecHelper
  extend RSpec::Core::SharedContext

  def edit_article
    page.find('.fa-pencil-square-o')
  end

  def add_article_button
    page.find('.add_article')
  end

  def edit_save
    page.find('.fa-check')
  end

  def chars_remaining
    page.find('.chars_remaining').text
  end

  def areas
    page.all("#media_appearances .media_appearance .expanded_info .description .area .name").map(&:text)
  end

  def subareas
    page.all("#media_appearances .media_appearance .expanded_info .description .subareas .subarea").map(&:text)
  end

  def expand_all_panels
    page.find('#media_appearances_controls #expand').click
  end

  def people_affected
    page.find(".metric#affected_people_count .value").text
  end

  def positivity_rating
    page.find(".metric#positivity_rating_rank .value").text
  end

  def violation_severity
    page.find(".metric#violation_severity_rank .value").text
  end

  def cancel_article_add
    page.find('.form #edit_cancel').click
    sleep(0.2)
  end

  def delete_article
    page.find('.media_appearance .delete_icon').click
    sleep(0.4)
  end

  def media_appearances
    page.all('#media_appearances .media_appearance')
  end
end
