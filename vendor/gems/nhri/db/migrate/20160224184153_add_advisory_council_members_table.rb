class AddAdvisoryCouncilMembersTable < ActiveRecord::Migration
  def change
    create_table :advisory_council_members do |t|
      t.string :first_name
      t.string :last_name
      t.string :title
      t.string :organization
      t.string :department
      t.string :mobile_phone
      t.string :office_phone
      t.string :home_phone
      t.string :email
      t.string :alternate_email
      t.string :bio
      t.timestamps
    end
  end
end
