require "rspec/core/rake_task"

desc "run all model specs"
task :models => :spec
RSpec::Core::RakeTask.module_eval do
  def pattern
    [File.join( '**', 'spec', 'models', '**', '*_spec.rb' ).to_s]
  end
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
RSpec::Core::RakeTask.module_eval do
  def pattern
    extras = []
    # get the root in the filesystem for all rails engines
    roots = Rails::Engine.subclasses.map{|e| e.config.root}
    # select only those engines that are under the Rails root
    modules = roots.select do |r|
      pu=[]
      r.ascend { |pr| pu<<pr }
      pu.any?{|pp| pp == Rails.root}
    end
    modules.each do |dir|
      extras << File.join( dir, 'spec', 'features', '**', '*_spec.rb' ).to_s
    end
    [@pattern] | extras
  end
end
