require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'
# require '../merb_rake_helper'

PLUGIN = "merb-cache"
NAME = "merb-cache"
GEM_VERSION = "0.0.1"
AUTHOR = "Ben Schwarz"
EMAIL = "ben@germanforblack.com"
HOMEPAGE = "..."
SUMMARY = "To provide a cleaner, more modular, heavier spec'd, more blackbox'd cache engine for Merb"

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency('merb', '>= 0.9.3')
  s.require_path = 'lib'
  s.autorequire = PLUGIN
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,spec}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the plugin locally"
task :install => [:package] do
  sh %{#{sudo} gem install pkg/#{NAME}-#{VERSION} --no-update-sources}
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

namespace :jruby do

  desc "Run :package and install the resulting .gem with jruby"
  task :install => :package do
    sh %{#{sudo} jruby -S gem install pkg/#{NAME}-#{Merb::VERSION}.gem --no-rdoc --no-ri}
  end

end

task :specs do
  cwd = Dir.getwd
  Dir.chdir(File.dirname(__FILE__) + "/spec")
  system("spec --format specdoc --colour merb-cache_spec.rb")
  Dir.chdir(cwd)
end

