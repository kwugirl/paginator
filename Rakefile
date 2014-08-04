require "rake/testtask"

Rake::TestTask.new("spec") do |t|
  t.libs.push ".", "spec"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end
