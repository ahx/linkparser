# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'rake'
require 'linkparser/version'

Gem::Specification.new do |gem|
	gem.name              = "linkparser"
	gem.version           = LinkParser::VERSION

	gem.summary           = 'a Ruby binding for the link-grammar library'
	gem.description       = [
		"A Ruby binding for the link-grammar library, a syntactic parser",
		"of English. See http://www.link.cs.cmu.edu/link/ for more",
		"information about the Link Grammar, and",
		"http://www.abisource.org/projects/link-grammar/ for information",
		"about the link-grammar library.",
  	  ].join( "\n" )

	gem.authors           = "Martin Chase, Michael Granger"
	gem.email             = ["stillflame@FaerieMUD.org", "ged@FaerieMUD.org"]
	gem.homepage          = 'http://deveiate.org/projects/Ruby-LinkParser/'

	gem.has_rdoc          = true
	gem.extra_rdoc_files  = Rake::FileList.new(%w[ChangeLog README* LICENSE]).to_a
	gem.require_paths    << 'ext'
	gem.extensions       << 'ext/extconf.rb'
	                                          
	gem.test_files        = Rake::FileList.new("spec/**/*_spec.rb", "spec/lib/**/*.rb").to_a
	
	gem.files             = Rake::FileList.new( "README*", "lib/**/*.rb", "ext/**/*.{c,h,rb}").to_a
	
	# Additional files	
  [
    "Rakefile",
    gem.name + "gemspec", 
    "Rakefile.local", 
    "ChangeLog",
    "LICENSE"
  ].each {|file| gem.files << file if File.exist?(file) }
  
  # Essential rake tasks
  gem.files << Rake::FileList.new("#rake/{documentation,helpers,packaging,testing}.rb")  	                                        

  # Dependencies 
  # TODO Differentiate between runtime and developement dependencies
  {
  	'rake'         => '>= 0.8.7',
  	'rake-compiler' => '~> 0.7.1',
  	'rcodetools'   => '>= 0.7.0.0',
  	'rcov'         => '>= 0.8.1.2.0',
  	'rdoc'         => '>= 2.4.3',
  	'RedCloth'     => '>= 4.0.3',  	
  	'rspec'        => '~> 2.0.1',
  	'ruby-termios' => '>= 0.9.6',
  	'text-format'  => '>= 1.0.0',
  	'tmail'        => '>= 1.2.3.1',
  	'diff-lcs'     => '>= 1.1.2'
  }.each do |name, version|
		gem.add_runtime_dependency( name, version )
	end

	gem.requirements << 'link-grammar >= 4.4.3'
end