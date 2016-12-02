module CorporateServices
  module OptionsHelper
    def start_date_options
      @strategic_plans.collect do |sp|
        description = sp.current? ?
          t('.current_year', :start => sp.start_date, :end => sp.end_date) :
          t('.other_years', :start =>sp.start_date, :end => sp.end_date)
        [description, sp.id, {:class => "h1_select"}]
      end
    end

    def priority_level_options
      (1..10).collect do |i|
        ["Strategic Priority #{i}",i]
      end
    end

  end
end
