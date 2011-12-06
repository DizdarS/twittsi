require "date"
require "uri"

# Copyright (C) 2010-2011, cloudHQ 
# All rights reserved.
#
# http://dev.twitter.com/pages/oauth_single_token
# Twitter developers - Using one access token with OAuth
# Many simple integrations just need to make use of a single user account.
# If this sounds like your situation, you don't need to implement the entire OAuth flow,
# but can instead begin from the point of having an access token for your own account.

require 'rubygems'

# OAuth (Open Authentication) is an open standard for authentication.
# It allows users to share their private resources stored on one site with another site
# without having to hand out their credentials, typically username and password.
require 'oauth'

# JSON (JavaScript Object Notation) is a text format for the serialization of structured data.
# JSON can represent four primitive types (strings, numbers, booleans, and null) and two structured types (objects and arrays).   
require 'json/pure'

#Use ActiveRecord without Rails
gem 'activerecord', '=2.3.8'
require 'activerecord' 


# YAML defines a serialization (data saving) format which stores information as human-readable text.
# YAML can be used with a variety of programming lan-guages and, in order to use it in Ruby, your code needs to use the yaml.rb file.
require 'yaml'

require 'cgi'

# OptionParser is a class for command-line option analysis.
# http://apidock.com/ruby/OptionParser
require 'optparse'
require 'optparse/time'

# OpenStruct allows you to create data objects and set arbitrary attributes.
# http://apidock.com/ruby/OptionParser
require 'ostruct'

# The Logger class provides a simple but sophisticated logging utility that anyone can use because
# it�s included in the Ruby 1.8.x standard library.
# http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/
require 'logger'

# Log4r is a comprehensive and flexible logging library written in Ruby for use in Ruby programs. 
# http://log4r.rubyforge.org/manual.html
# require 'log4r'
# include Log4r

require 'db_helper_friend'
require 'db_helper_message'
require 'parse_arguments'
require 'twitter_http_response_code'
require 'twitter_init'
require 'twitter_exec'

DATABASE_YML                     = 'twitter_database.yml'

class User < ActiveRecord::Base
  has_many :followers
  has_many :friends
  has_many :direct_messages
  
end

class Follower < ActiveRecord::Base
  #@37signals, @basecampnews, @dropbox, @sugarsync, @googledocs
  #belongs_to :user
  
end
class DirectMessage < ActiveRecord::Base
  belongs_to :user
end

class Friend < ActiveRecord::Base

end

class Message < ActiveRecord::Base
  
end

def open_database_connection
  dbconfig = YAML::load(File.open(DATABASE_YML))
  @database_connection = ActiveRecord::Base.establish_connection(dbconfig)
end

def close_database_connection
  ActiveRecord::Base.remove_connection #if defined?(ActiveRecord)
end
##############################################################################################
#puts "!!!!!!!!!!! Script is started  !!!!!!!!!" # Needed! http://optionparser.rubyforge.org/
##############################################################################################

$i = 0
#file = open('logfile.log', File::WRONLY | File::CREAT)
#$logger = Logger.new(file)
#$logger.level = Logger::DEBUG
#  DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
# "%s, [%s#%d] %5s -- %s: %s\n"
#$logger.sev_threshold = Logger::DEBUG
#$logger.datetime_format = "%Y-%m-%d %H:%M:%S"
#$logger.datetime_format = "%Y-%m-%d"
#$logger.formatter = proc { |severity, datetime, progname, msg|
##                            dt = datetime.strftime("%Y-%m-%d %H:%M:%S")
#                            #progname = "#{self.class.name}.#{__method__}"
#                            "#{dt} #{severity}: #{msg}\n"
#                         }

#print "\n\ncloudHQ cloudFS Utility v1.0 - ", DateTime.now(), "\n\n" 
#$logger.info "------------------------- START -------------------------"
options = ParseArguments.parse(ARGV)

puts ("options = #{options.inspect}")

if (options.length > 0)
  twitter_init = TwitterInit.new(options)
  open_database_connection
  twitter_exec = TwitterExec.new(options, twitter_init.access_token)
  twitter_exec.exec_operation
  close_database_connection
#  twitter_util.close_database_log
end




#$logger.info "------------------------- END -------------------------"
#$logger.close
#################################################
#puts "!!!!!!!!!!! Script is finished !!!!!!!!!" #
#################################################
