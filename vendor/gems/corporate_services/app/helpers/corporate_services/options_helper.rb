module CorporateServices
  module OptionsHelper
    def start_date_options
      StrategicPlan.all_with_current.collect do |sp|
        description = sp.current? ?
          t('.current_year', :start => sp.start_date, :end => sp.end_date) :
          t('.other_years', :start =>sp.start_date, :end => sp.end_date)
        [description, sp.id, {:class => "h1_select"}]
      end
    end
  end
end
