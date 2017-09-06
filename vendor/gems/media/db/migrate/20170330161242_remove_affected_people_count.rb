class RemoveAffectedPeopleCount < ActiveRecord::Migration[5.0]
  def change
    remove_column :media_appearances, :affected_people_count
    remove_column :advisory_council_issues, :affected_people_count
  end
end
