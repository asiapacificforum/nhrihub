namespace :strategic_plan do
  desc "populate all models within the strategic plan module"
  task :populate => [:populate_sp, :populate_accred_groups]

  def populate_strategic_plan(strategic_plan)
    2.times do |i|
      sp = FactoryGirl.create(:strategic_priority, :priority_level => i+1, :strategic_plan_id => strategic_plan.id)
      2.times do
        pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
        2.times do
          o = FactoryGirl.create(:outcome, :planned_result => pr)
          2.times do
            a = FactoryGirl.create(:activity, :outcome => o)
            2.times do
              FactoryGirl.create(:performance_indicator, :well_populated, :activity => a)
            end
          end
        end
      end
    end
  end

  desc "re-initialize strategic plans"
  task :depopulate => :environment do
    StrategicPlan.destroy_all
    MediaAppearance.destroy_all
    Project.destroy_all
  end

  desc "re-initialize strategic plans"
  task :populate_sp => "strategic_plan:depopulate" do
    previous_strategic_plan = FactoryGirl.create(:strategic_plan, :created_at => Date.new(Date.today.year-1,1,1))
    current_strategic_plan = FactoryGirl.create(:strategic_plan, :created_at => Date.new(Date.today.year,1,1))
    populate_strategic_plan(previous_strategic_plan)
    populate_strategic_plan(current_strategic_plan)
  end

  desc "set up accreditation required doc groups"
  task :populate_accred_groups => :environment do
    titles = ["Statement of Compliance", "Enabling Legislation", "Organization Chart", "Annual Report", "Budget"]
    titles.each do |title|
      AccreditationDocumentGroup.create(:title => title)
    end
  end
end
