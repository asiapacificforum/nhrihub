class AdvisoryCouncilIssueTest
  def self.populate_test_data
    aci = FactoryGirl.build(:advisory_council_issue,
                            :hr_violation_subarea,
                            :crc_subarea,
                            :title => "Fantasy land",
                            # this time is stored as its UTC equivalent 12/31/14
                            # so the date method returns the intended value, 1/1/15
                            :created_at => DateTime.new(2015,1,1,0,0,0,'-8'))
    aci.save

    aci = FactoryGirl.build(:advisory_council_issue,
                            :hr_violation_subarea,
                            :crc_subarea,
                            :title => "May the force be with you",
                            :created_at => DateTime.new(2014,1,1,0,0,0,'-8'))
    aci.save

    6.times do |i|
      aci = FactoryGirl.build(:advisory_council_issue,
                              :no_f_in_title,
                              :si_area,
                              :created_at => DateTime.new(2014,1,1,0,0,0,'-8'))
      aci.save
    end
  end
end
