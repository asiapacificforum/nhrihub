namespace :nhri do
  desc "populate all nhri modules"
  task :populate => :environment do
    sub_modules = { :advisory_council => [ :terms_of_reference,
                                           :membership,
                                           :meeting_minutes,
                                           :issues ],
                    :human_rights_indicators => [],
                    :accreditation => [ :internal_documents,
                                        :reference_documents ] }
    sub_modules.each do |(sub_module,sub_sub_modules)|
      if sub_sub_modules.empty?
        Rake::Task["nhri:#{sub_module}"].invoke
      else
        sub_sub_modules.each do |sub_sub_module|
          Rake::Task["nhri:#{sub_module}:#{sub_sub_module}"].invoke
        end #/sub_sub_modules.each
      end #/if
    end #/sub_modules.each
  end #/task
end #/namespace
