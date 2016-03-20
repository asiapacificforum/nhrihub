require 'rspec/core/shared_context'
require 'notes_spec_common_helpers'

module NotesSpecHelpers
  extend RSpec::Core::SharedContext
  include NotesSpecCommonHelpers
  def setup_note
    FactoryGirl.create(:note,
                       :notable_type => "Nhri::Indicator",
                       :notable_id => Nhri::Indicator.first.id)
  end
end
