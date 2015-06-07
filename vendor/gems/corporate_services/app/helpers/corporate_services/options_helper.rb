module CorporateServices
  module OptionsHelper
    def start_date_options
      StrategicPlan.all_with_current.collect do |sp|
        description = sp.current? ?
          t('.current_year', :start => sp.start_date, :end => sp.end_date) :
          t('.other_years', :start =>sp.start_date, :end => sp.end)
        [description, sp.id]
      end
    end
  end
end
