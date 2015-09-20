require 'rspec/core/shared_context'
require 'notes_spec_common_helpers'

module NotesSpecHelpers
  extend RSpec::Core::SharedContext
  include NotesSpecCommonHelpers
  def setup_note
    FactoryGirl.create(:note, :notable_type => "MediaAppearance", :notable_id => MediaAppearance.first.id)
  end
end
