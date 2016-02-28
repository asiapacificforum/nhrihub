require 'rspec/core/shared_context'

module AdvisoryCouncilMembershipSpecHelper
  extend RSpec::Core::SharedContext

  def delete_first_member
    page.all('#members .member .icon.delete').first
  end

  def first_member_edit
    page.all('#members .member .icon.edit').first
  end

  def modal_close_icon
    page.find('#new_member_modal button.close')
  end

  def add_member_cancel_icon
    page.find('#new_member_modal i#cancel')
  end
end
