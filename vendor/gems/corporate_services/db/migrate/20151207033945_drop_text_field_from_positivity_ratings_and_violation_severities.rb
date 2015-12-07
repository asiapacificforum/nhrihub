class DropTextFieldFromPositivityRatingsAndViolationSeverities < ActiveRecord::Migration
  def change
    remove_column :positivity_ratings, :text, :text
    remove_column :violation_severities, :text, :text
  end
end
