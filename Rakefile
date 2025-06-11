require 'bundler/gem_tasks'
require 'rake/extensiontask'
require 'rake/testtask'
require 'rake/clean'

CLEAN.include(
  "lib/syck.bundle",
  "lib/syck.dll",
  "lib/syck.so",
  "tmp",
  "ext/syck/*.o",
  "ext/syck/*.bundle",
  "ext/syck/*.so",
  "ext/syck/*.dll",
  "ext/syck/Makefile",
  "ext/syck/mkmf.log",
  "ext/syck/extconf.h"
)

CLOBBER.include(
  "ext/syck/gram.c", # Generated from gram.y
  "ext/syck/gram.h"  # Generated from gram.y
)

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/test_*.rb']
end
Rake::ExtensionTask.new('syck')

task :default => [:compile, :test]
