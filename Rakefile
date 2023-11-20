# frozen_string_literal: true

require "rake"
require "rspec/core/rake_task"
namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = Dir.glob("spec/aserto/**/*_spec.rb")
    t.rspec_opts = "--format documentation"
  end

  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = Dir.glob("spec/integration/**/*_spec.rb")
    t.rspec_opts = "--format documentation"
  end

  desc "Run all tests"
  task :all do
    ["spec:unit", "spec:integration"].each do |t|
      Rake::Task[t].execute
    end
  end
end

task default: "spec:unit"
