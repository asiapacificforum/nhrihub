require 'rspec/core/shared_context'

module AdvisoryCouncilIssueSpecHelper
  extend RSpec::Core::SharedContext

  def single_item_selector
    '#advisory_council_issues .advisory_council_issue'
  end

  def advisory_council_issues
    page.all(single_item_selector)
  end

  def expand_all_panels
    page.find('#advisory_council_issues_controls #expand').click
    sleep(0.3)
  end

  def first_article_link
    Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.article_link.gsub(/http/,'')
  end

  def delete_article_link_field
    fill_in("advisory_council_issue_article_link", :with => "")
    # b/c setting the value by javascript (previous line) does not trigger the input event, as it would for a real user input
    if !page.driver.browser.is_a?(Capybara::Poltergeist::Browser)
      page.execute_script("event = new Event('input'); $('.article_link')[0].dispatchEvent(event)")
    end
  end

  def clear_filter_fields
    page.find('.fa-refresh').click
    sleep(0.2) #javascript
  end

end
