require 'rspec/core/shared_context'

module ComplaintsBehaviourHelpers
  extend RSpec::Core::SharedContext
  def first_complaint
    page.all('#complaints .complaint')[0]
  end

  def complaint_documents
    page.find('#complaint_documents')
  end

  def assignee_history
    find('#assignees')
  end

  def expand
    find('#expand').click
  end

  def add_complaint
    page.find('#add_complaint')
  end
end
