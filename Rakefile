#!rake -*- ruby -*-
#
# LinkParser rakefile
#
# Based on various other Rakefiles, especially one by Ben Bleything
#
# Copyright (c) 2007-2010 The FaerieMUD Consortium
#
# Authors:
#  * Michael Granger <ged@FaerieMUD.org>
#

BEGIN {
	require 'rbconfig'
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname

	libdir = basedir + "lib"
	extdir = libdir + Config::CONFIG['sitearch']

	$LOAD_PATH.unshift( basedir.to_s ) unless $LOAD_PATH.include?( basedir.to_s )
	$LOAD_PATH.unshift( libdir.to_s ) unless $LOAD_PATH.include?( libdir.to_s )
	$LOAD_PATH.unshift( extdir.to_s ) unless $LOAD_PATH.include?( extdir.to_s )
}

begin
	require 'readline'
	include Readline
rescue LoadError
	# Fall back to a plain prompt
	def readline( text )
		$stderr.print( text.chomp )
		return $stdin.gets
	end
end

begin
	require 'rubygems'
rescue LoadError
	module Gem
		class Specification; end
	end
end

require 'rbconfig'
require 'rake'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/clean'

$dryrun = false

### Config constants
BASEDIR       = Pathname.new( __FILE__ ).dirname.relative_path_from( Pathname.getwd )

PROJECT_NAME  = 'LinkParser'
# Load RubyGem specification
GEMSPEC = eval(File.read(BASEDIR + "linkparser.gemspec"))

PKG_NAME      = GEMSPEC.name
PKG_SUMMARY   = 'a Ruby binding for the link-grammar library'

BINDIR        = BASEDIR + 'bin'
LIBDIR        = BASEDIR + 'lib'
EXTDIR        = BASEDIR + 'ext'
DOCSDIR       = BASEDIR + 'docs'
PKGDIR        = BASEDIR + 'pkg'
DATADIR       = BASEDIR + 'data'

MANUALDIR     = DOCSDIR + 'manual'

# Cruisecontrol stuff
CC_BUILD_LABEL     = ENV['CC_BUILD_LABEL']
CC_BUILD_ARTIFACTS = ENV['CC_BUILD_ARTIFACTS'] || 'artifacts'

require "linkparser/version"
if buildrev = ENV['CC_BUILD_LABEL']
	PKG_VERSION = LinkParser::VERSION + '.' + buildrev
else
	PKG_VERSION = LinkParser::VERSION
end

PKG_FILE_NAME = "#{PKG_NAME.downcase}-#{PKG_VERSION}"
GEM_FILE_NAME = "#{PKG_FILE_NAME}.gem"

# Universal VCS constants
DEFAULT_EDITOR  = 'vi'
COMMIT_MSG_FILE = 'commit-msg.txt'
FILE_INDENT     = " " * 12
LOG_INDENT      = " " * 3

ARTIFACTS_DIR = Pathname.new( CC_BUILD_ARTIFACTS )

BIN_FILES     = Rake::FileList.new( "#{BINDIR}/*" )
LIB_FILES     = Rake::FileList.new( "#{LIBDIR}/**/*.rb" )
EXT_FILES     = Rake::FileList.new( "#{EXTDIR}/**/*.{c,h,rb}" )
DATA_FILES    = Rake::FileList.new( "#{DATADIR}/**/*" )

SPECDIR       = BASEDIR + 'spec'
SPEC_FILES    = Rake::FileList.new( "#{SPECDIR}/**/*_spec.rb", "#{SPECDIR}/lib/**/*.rb" )

TESTDIR       = BASEDIR + 'tests'
TEST_FILES    = Rake::FileList.new( "#{TESTDIR}/**/*.tests.rb" )

RAKE_TASKDIR  = BASEDIR + 'rake'
RAKE_TASKLIBS = Rake::FileList.new( "#{RAKE_TASKDIR}/*.rb" )

RAKE_TASKLIBS_URL = 'http://repo.deveiate.org/rake-tasklibs'

LOCAL_RAKEFILE = BASEDIR + 'Rakefile.local'

EXTRA_PKGFILES = Rake::FileList.new

RELEASE_FILES = GEMSPEC.test_files + GEMSPEC.files

RELEASE_ANNOUNCE_ADDRESSES = [
	"Ruby-Talk List <ruby-talk@ruby-lang.org>",
]

COVERAGE_MINIMUM = ENV['COVERAGE_MINIMUM'] ? Float( ENV['COVERAGE_MINIMUM'] ) : 85.0
RCOV_EXCLUDES = 'spec,tests,/Library/Ruby,/var/lib,/usr/local/lib'
RCOV_OPTS = [
	'--exclude', RCOV_EXCLUDES,
	'--xrefs',
	'--save',
	'--callsites',
	#'--aggregate', 'coverage.data' # <- doesn't work as of 0.8.1.2.0
  ]


### Load some task libraries that need to be loaded early
if !RAKE_TASKDIR.exist?
	$stderr.puts "It seems you don't have the build task directory. Shall I fetch it "
	ans = readline( "for you? [y]" )
	ans = 'y' if !ans.nil? && ans.empty?

	if ans =~ /^y/i
		$stderr.puts "Okay, fetching #{RAKE_TASKLIBS_URL} into #{RAKE_TASKDIR}..."
		system 'hg', 'clone', RAKE_TASKLIBS_URL, "./#{RAKE_TASKDIR}"
		if ! $?.success?
			fail "Damn. That didn't work. Giving up; maybe try manually fetching?" +
			  "If you don't have Mercurial installed, you might want to try the Git mirror: https://github.com/ged/geds-rake-tasklibs"
		end
	else
		$stderr.puts "Then I'm afraid I can't continue. Best of luck."
		fail "Rake tasklibs not present."
	end

  RAKE_TASKLIBS.include( "#{RAKE_TASKDIR}/*.rb" )
end

require RAKE_TASKDIR + 'helpers.rb'
include RakefileHelpers

# Set the build ID if the mercurial executable is available
if hg = which( 'hg' )
	id = `#{hg} id -n`.chomp
	PKG_BUILD = "pre%03d" % [(id.chomp[ /^[[:xdigit:]]+/ ] || '1')]
else
	PKG_BUILD = 'pre000'
end
SNAPSHOT_PKG_NAME = "#{PKG_FILE_NAME}.#{PKG_BUILD}"
SNAPSHOT_GEM_NAME = "#{SNAPSHOT_PKG_NAME}.gem"

# Documentation constants
API_DOCSDIR = DOCSDIR + 'api'
README_FILE = 'README'
RDOC_OPTIONS = [
	'--tab-width=4',
	'--show-hash',
	'--include', BASEDIR.to_s,
	"--main=#{README_FILE}",
	"--title=#{PKG_NAME}",
  ]
YARD_OPTIONS = [
	'--use-cache',
	'--no-private',
	'--protected',
	'-r', README_FILE,
	'--exclude', 'extconf\\.rb',
	'--files', 'ChangeLog,LICENSE',
	'--output-dir', API_DOCSDIR.to_s,
	'--title', "#{PKG_NAME} #{PKG_VERSION}",
  ]

# Release constants
SMTP_HOST = "mail.faeriemud.org"
SMTP_PORT = 465 # SMTP + SSL

# Project constants
PROJECT_HOST = 'deveiate.org'
PROJECT_PUBDIR = '/usr/local/www/public/code'
PROJECT_DOCDIR = "#{PROJECT_PUBDIR}/#{PKG_NAME}"
PROJECT_SCPPUBURL = "#{PROJECT_HOST}:#{PROJECT_PUBDIR}"
PROJECT_SCPDOCURL = "#{PROJECT_HOST}:#{PROJECT_DOCDIR}"

# Gem dependencies: gemname => version
DEPENDENCIES = Hash[GEMSPEC.runtime_dependencies.map{ |gem| [ gem.name, gem.requirement.to_s ]  }]

# Developer Gem dependencies: gemname => version
DEVELOPMENT_DEPENDENCIES = Hash[GEMSPEC.development_dependencies.map{ |gem| [ gem.name, gem.requirement.to_s ]  }]

$trace = Rake.application.options.trace ? true : false
$dryrun = Rake.application.options.dryrun ? true : false
$include_dev_dependencies = false

# Load any remaining task libraries
RAKE_TASKLIBS.each do |tasklib|
	next if tasklib.to_s =~ %r{/helpers\.rb$}
	begin
		trace "  loading tasklib %s" % [ tasklib ]
		import tasklib
	rescue ScriptError => err
		fail "Task library '%s' failed to load: %s: %s" %
			[ tasklib, err.class.name, err.message ]
		trace "Backtrace: \n  " + err.backtrace.join( "\n  " )
	rescue => err
		log "Task library '%s' failed to load: %s: %s. Some tasks may not be available." %
			[ tasklib, err.class.name, err.message ]
		trace "Backtrace: \n  " + err.backtrace.join( "\n  " )
	end
end

# Load any project-specific rules defined in 'Rakefile.local' if it exists
import LOCAL_RAKEFILE if LOCAL_RAKEFILE.exist?


#####################################################################
###	T A S K S 	
#####################################################################

### Default task
task :default  => [:clean, :local, :spec, :apidocs, :package]

### Task the local Rakefile can append to -- no-op by default
task :local

### Task: clean
CLEAN.include 'coverage', '**/*.orig', '**/*.rej'
CLOBBER.include 'artifacts', 'coverage.info', 'ChangeLog', PKGDIR

### Task: changelog
file 'ChangeLog' do |task|  
	log "Updating #{task.name}"

	changelog = make_changelog()
	File.open( task.name, 'w' ) do |fh|
		fh.print( changelog )
	end
end



### Task: cruise (Cruisecontrol task)
desc "Cruisecontrol build"
task :cruise => [:clean, 'spec:quiet', :package] do |task|
	raise "Artifacts dir not set." if ARTIFACTS_DIR.to_s.empty?
	artifact_dir = ARTIFACTS_DIR.cleanpath + (CC_BUILD_LABEL || Time.now.strftime('%Y%m%d-%T'))
	artifact_dir.mkpath

	coverage = BASEDIR + 'coverage'
	if coverage.exist? && coverage.directory?
		$stderr.puts "Copying coverage stats..."
		FileUtils.cp_r( 'coverage', artifact_dir )
	end

	$stderr.puts "Copying packages..."
	FileUtils.cp_r( FileList['pkg/*'].to_a, artifact_dir )
end


desc "Update the build system to the latest version"
task :update_build do
	log "Updating the build system"
	run 'hg', '-R', RAKE_TASKDIR, 'pull', '-u'
	log "Updating the Rakefile"
	sh 'rake', '-f', RAKE_TASKDIR + 'Metarakefile'
end

