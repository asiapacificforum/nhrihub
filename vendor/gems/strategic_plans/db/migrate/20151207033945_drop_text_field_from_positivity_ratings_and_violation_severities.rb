class DropTextFieldFromPositivityRatingsAndViolationSeverities < ActiveRecord::Migration[4.2]
  def change
    remove_column :positivity_ratings, :text, :text
    remove_column :violation_severities, :text, :text
  end
end
