require 'rspec/core/shared_context'

module CorporateServicesAdminSpecHelpers
  extend RSpec::Core::SharedContext
  def strategic_plan_list
    page.all('#strategic_plans .strategic_plan td:nth-child(1)').map(&:text)
  end

  def strategic_plan_menu
    page.find('#strat_plan').hover
    sleep(0.5)
    page.all('#strat_plan #sp_item').map(&:text)
  end

  def save_strategic_plan
    page.find('#save').click
    wait_for_ajax
  end

  def delete_plan
    page.all('.delete_strategic_plan')[0].click
  end

  def delete_current_plan
    page.all('.delete_strategic_plan')[-1].click
  end
end
