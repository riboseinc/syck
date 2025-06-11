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

# Check bison availability and version
def check_bison_version
  return false unless system('bison --version > /dev/null 2>&1')

  version_output = `bison --version 2>&1`.lines.first
  return false unless version_output

  # Extract version number (e.g., "bison (GNU Bison) 3.8.2" -> "3.8.2")
  version_match = version_output.match(/bison.*?(\d+\.\d+(?:\.\d+)?)/)
  return false unless version_match

  version = version_match[1]
  version_parts = version.split('.').map(&:to_i)
  required_parts = [3, 8, 2]  # Require bison >= 3.8.2

  # Compare version: require >= 3.8.2
  (version_parts <=> required_parts) >= 0
end

# Generate both gram.c and gram.h
file 'ext/syck/gram.c' => 'ext/syck/gram.y' do |t|
  Dir.chdir('ext/syck') do
    unless check_bison_version
      current_version = `bison --version 2>&1`.lines.first.match(/(\d+\.\d+(?:\.\d+)?)/)[1] rescue "unknown"
      raise <<~ERROR
        Bison >= 3.8.2 is required to generate grammar from gram.y.
        Current version: #{current_version}

        Please install or upgrade bison.
        Or use the existing pre-generated gram.c file by ensuring it exists.
      ERROR
    end

    # Generate both .c and .h files
    # -d flag generates the header file
    # --output=gram.c specifies the output file name
    system('bison -d --output=gram.c gram.y') or raise "Failed to generate grammar"
    puts "Grammar generated successfully (gram.c and gram.h)"
  end
end

# Track gram.h as a generated file
file 'ext/syck/gram.h' => 'ext/syck/gram.y' do |t|
  # This will be generated along with gram.c, so just ensure gram.c is built
  Rake::Task['ext/syck/gram.c'].invoke
end

# Generate grammar files before any compilation
desc "Generate grammar files from gram.y"
task :generate_grammar => ['ext/syck/gram.c']

# Configure the extension task
Rake::ExtensionTask.new('syck') do |ext|
  ext.lib_dir = 'lib'
  ext.source_pattern = "*.{c,y}"
end

# Task for development workflow
desc "Clean, generate grammar, and compile (full development build)"
task :dev_build => [:clobber, :generate_grammar, :compile]

task :default => [:clean, :compile, :test]
