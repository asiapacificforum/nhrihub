module StrategicPlans
  module OptionsHelper

    def priority_level_options
      (1..10).collect do |i|
        ["Strategic Priority #{i}",i]
      end
    end

  end
end
