require 'bundler/setup'

gemspec = eval(File.read("legacy-venice.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["legacy-venice.gemspec"] do
  system "gem build legacy-venice.gemspec"
end
