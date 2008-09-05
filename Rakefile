require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'
require "spec/rake/spectask"
require 'merb-core'

PLUGIN = "merb-cache"
NAME = "merb-cache"
GEM_VERSION = "0.0.1"
AUTHOR = "Ben Schwarz"
EMAIL = "ben@germanforblack.com"
HOMEPAGE = "..."
SUMMARY = "To provide a cleaner, more modular, heavier spec'd, more blackbox'd cache engine for Merb"

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = Merb::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency('merb', '>= 0.9.3')
  s.require_path = 'lib'
  s.autorequire = PLUGIN
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{lib,spec}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the plugin locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{NAME}-#{Merb::VERSION} --no-update-sources}
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

desc "Run all specs"
Spec::Rake::SpecTask.new("specs") do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Dir["spec/**/*_spec.rb"].sort
  t.rcov = true
  t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
  t.rcov_opts << '--only-uncovered'
end

##############################################################################
# memcached
##############################################################################
MEMCACHED_PORTS = 43042..43043

namespace :memcached do
  desc "Start the memcached instances for specs"
  task :start do
    log = "/tmp/memcached.log"
    system ">#{log}"

    verbosity = (ENV['DEBUG'] ? "-vv" : "")

    (MEMCACHED_PORTS).each do |port|
      system "memcached #{verbosity} -p #{port} >> #{log} 2>&1 &"
    end
  end

  desc "Kill the memcached instances"
  task :kill do
    `ps awx`.split("\n").grep(/#{MEMCACHED_PORTS.to_a.join('|')}/).map do |process| 
      system("kill -9 #{process.to_i}") rescue nil
    end
  end
end