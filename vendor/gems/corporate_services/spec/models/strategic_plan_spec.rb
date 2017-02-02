require 'rails_helper'

describe ".current class method" do
  before do
    previous_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year-1,1,1))
    @current_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year,1,1))
  end

  it "should return the current strategic plan" do
    expect(StrategicPlan.current.first).to eq @current_strategic_plan
  end
end

describe ".most_recent" do
  before do
    @first_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year-1,1,1))
    @second_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year,1,1))
  end

  it "should return the StrategicPlan instance with the most recent start_date" do
    expect(StrategicPlan.most_recent).to eq @second_strategic_plan
  end
end

describe "eager loading via scopes" do
  before do
    previous_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year-1,1,1))
    current_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year,1,1))

    #2.times do |i|
      #sp = FactoryGirl.create(:strategic_priority, :priority_level => i+1, :strategic_plan_id => previous_strategic_plan.id)
      #2.times do
        #pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
        #2.times do
          #o = FactoryGirl.create(:outcome, :planned_result => pr)
          #2.times do
            #a = FactoryGirl.create(:activity, :outcome => o)
            #2.times do
              #pi = FactoryGirl.create(:performance_indicator, :activity => a)
              #2.times do
                #FactoryGirl.create(:media_appearance, :performance_indicators => [pi])
                #FactoryGirl.create(:project, :performance_indicators => [pi])
              #end
            #end
          #end
        #end
      #end
    #end

    2.times do |i|
      sp = FactoryGirl.create(:strategic_priority, :priority_level => i+1, :strategic_plan_id => current_strategic_plan.id)
      2.times do
        pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
        2.times do
          o = FactoryGirl.create(:outcome, :planned_result => pr)
          2.times do
            a = FactoryGirl.create(:activity, :outcome => o)
            2.times do
              pi = FactoryGirl.create(:performance_indicator, :activity => a)
              2.times do
                MediaAppearance.create(:title => "foo", :performance_indicators => [pi])
                FactoryGirl.create(:project, :performance_indicators => [pi])
              end
            end
          end
        end
      end
    end
  end

  let(:strategic_plan){StrategicPlan.current.eager_loaded_associations.first}
  let(:json){ strategic_plan.to_json }
  let(:ruby){ JSON.parse(json) }

  it "should create a serialized json version" do
    expect(strategic_plan.to_json).to be_a String
    expect(JSON.parse(json)).to be_a Hash
    expect(ruby).to be_a Hash
    expect(ruby["strategic_priorities"].length).to eq 2

    strategic_priority = ruby["strategic_priorities"][0]
    expect(strategic_priority.keys).to match_array ["id", "priority_level", "description", "strategic_plan_id", "url", "create_planned_result_url", "planned_results", "description_error"]
    expect(ruby["strategic_priorities"][0]["planned_results"].length).to eq 2
    expect(ruby["strategic_priorities"][1]["planned_results"].length).to eq 2

    planned_result = strategic_priority["planned_results"][0]
    expect(planned_result["outcomes"].length).to eq 2
    expect(planned_result.keys).to match_array ["id", "description", "strategic_priority_id", "index", "url", "indexed_description", "outcomes", "create_outcome_url", "description_error"]

    outcome = planned_result["outcomes"][0]
    expect(outcome["activities"].length).to eq 2
    expect(outcome.keys).to match_array ["id", "planned_result_id", "activities", "description", "index", "indexed_description", "create_activity_url", "url", "description_error"]

    activity = outcome["activities"][0]
    expect(activity["performance_indicators"].length).to eq 2
    expect(activity.keys).to match_array ["id", "outcome_id", "description", "index", "indexed_description", "performance_indicators", "url", "description_error", "create_performance_indicator_url"]

    performance_indicator = activity["performance_indicators"][0]
    expect(performance_indicator.keys).to match_array ["id", "activity_id", "description", "target", "index", "indexed_description", "url", "indexed_target", "description_error", "reminders", "create_reminder_url", "notes", "media_appearance_titles", "project_titles", "create_note_url"]

    expect(performance_indicator["project_titles"].length).to eq 2
    expect(performance_indicator["media_appearance_titles"].length).to eq 2
  end
end

describe ".load_sql" do
  before do
    previous_strategic_plan = FactoryGirl.create(:strategic_plan, :well_populated, :start_date => Date.new(Date.today.year-1,1,1))
    current_strategic_plan = FactoryGirl.create(:strategic_plan, :well_populated, :start_date => Date.new(Date.today.year,1,1))
  end

  let(:json){StrategicPlan.load_sql}
  let(:ruby){ JSON.parse(json)[0] }

  it "should create a serialized json version" do
    expect(JSON.parse(json)[0]).to be_a Hash
    expect(ruby).to be_a Hash
    expect(ruby["strategic_priorities"].length).to eq 2

    strategic_priority = ruby["strategic_priorities"][0]
    expect(strategic_priority.keys).to match_array ["id", "priority_level", "description", "strategic_plan_id", "planned_results"] #, "url", "create_planned_result_url", "description_error"]
    expect(ruby["strategic_priorities"][0]["planned_results"].length).to eq 2
    expect(ruby["strategic_priorities"][1]["planned_results"].length).to eq 2

    planned_result = strategic_priority["planned_results"][0]
    expect(planned_result["outcomes"].length).to eq 2
    expect(planned_result.keys).to match_array ["id", "description", "strategic_priority_id", "index", "indexed_description", "outcomes"] #, "create_outcome_url", "description_error", "url"]

    outcome = planned_result["outcomes"][0]
    expect(outcome["activities"].length).to eq 2
    expect(outcome.keys).to match_array ["id", "planned_result_id", "activities", "description", "index", "indexed_description" ] #, "url", "description_error", "create_activity_url"]

    activity = outcome["activities"][0]
    expect(activity["performance_indicators"].length).to eq 2
    expect(activity.keys).to match_array ["id", "outcome_id", "description", "index", "indexed_description", "performance_indicators"] #, "url", "description_error", "create_performance_indicator_url"]

    performance_indicator = activity["performance_indicators"][0]
    expect(performance_indicator.keys).to match_array ["id", "activity_id", "description", "target", "index", "indexed_description", "indexed_target", "reminders", "notes", "projects", "media_appearances"] #, "media_appearance_titles", "project_titles", "description_error", "create_reminder_url", "url", "create_note_url"]

    expect(performance_indicator["projects"].length).to eq 2
    expect(performance_indicator["media_appearances"].length).to eq 2
  end
end

describe "create new plan and copy previous elements" do
  before do
    @previous_strategic_plan = FactoryGirl.create(:strategic_plan, :well_populated, :start_date => Date.new(Date.today.year-1,1,1))
  end

  it "should copy previous strategic plan elements if created with copy flag set" do
    new_strategic_plan = StrategicPlan.new(:copy => true)
    new_strategic_plan.save
    expect(new_strategic_plan.strategic_priorities.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[0].reload.planned_results.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].reload.planned_results.length).to eq 2

    expect(new_strategic_plan.strategic_priorities[0].planned_results[0].reload.outcomes.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[0].planned_results[1].reload.outcomes.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[0].reload.outcomes.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[1].reload.outcomes.length).to eq 2

    expect(new_strategic_plan.strategic_priorities[0].planned_results[0].outcomes[0].reload.activities.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[0].planned_results[0].outcomes[1].reload.activities.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[0].planned_results[1].outcomes[0].reload.activities.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[0].planned_results[1].outcomes[1].reload.activities.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[0].outcomes[0].reload.activities.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[0].outcomes[1].reload.activities.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[1].outcomes[0].reload.activities.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[1].outcomes[1].reload.activities.length).to eq 2

    expect(new_strategic_plan.strategic_priorities[0].planned_results[0].outcomes[0].activities[0].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[0].planned_results[0].outcomes[0].activities[1].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[0].planned_results[0].outcomes[1].activities[0].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[0].planned_results[0].outcomes[1].activities[1].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[0].planned_results[1].outcomes[0].activities[0].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[0].planned_results[1].outcomes[0].activities[1].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[0].planned_results[1].outcomes[1].activities[0].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[0].planned_results[1].outcomes[1].activities[1].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[0].outcomes[0].activities[0].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[0].outcomes[0].activities[1].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[0].outcomes[1].activities[0].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[0].outcomes[1].activities[1].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[1].outcomes[0].activities[0].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[1].outcomes[0].activities[1].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[1].outcomes[1].activities[0].reload.performance_indicators.length).to eq 2
    expect(new_strategic_plan.strategic_priorities[1].planned_results[1].outcomes[1].activities[1].reload.performance_indicators.length).to eq 2
  end

  it "should create a blank StrategicPlan if copy flag is set to false" do
    new_strategic_plan = StrategicPlan.new(:copy => false)
    new_strategic_plan.save
    expect(new_strategic_plan.strategic_priorities).to be_empty
  end

  it "should create a blank StrategicPlan if copy flag is not present" do
    new_strategic_plan = StrategicPlan.new
    new_strategic_plan.save
    expect(new_strategic_plan.strategic_priorities).to be_empty
  end

end
