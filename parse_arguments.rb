# OptionParser is a class for command-line option analysis.
# http://apidock.com/ruby/OptionParser
class ParseArguments
    #
    # Return a structure describing the options.
    #
    def self.parse(args)
      # The options specified on the command line will be collected in *options*.
      # We set default values here.
      options = Hash.new # { :send_email => true }
      
      if (args.length == 0)
        args[0] = "-h"
      end
        
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: twitter_cli.rb [options]"

        opts.separator ""
        opts.separator "Specific options:"
        
        # Get followers and send messages.
        opts.on("-m <service>,<requests>,<sleep>,<who>", "--messages <service>,<requests>,<sleep>,<who>", Array, "Send messages to cloudhq_net and sugarsync users: twitter_cli.rb sugarsync,3,3,Senad") do |lib|
          options[:option_send_message] = true
          
          if (lib[0].to_s.downcase == "cloudhq_net"   ||
              lib[0].to_s.downcase == "dropbox"       ||
              lib[0].to_s.downcase == "sugarsync"     ||
              lib[0].to_s.downcase == "basecamp"      ||
              lib[0].to_s.downcase == "googledocs") && lib.length == 4
            options[:service               ] = lib[0]
            options[:max_number_of_requests] = lib[1]
            options[:sleep_between_requests] = lib[2]
            options[:who]                    = lib[3]
          else
            args[0] = "-h"
          end
        end
        # Get Friends.
        opts.on("-i", "--info", "Get info about friends and followers...") do |lib|
          if args.length == 1
            options[:option_get_info]   = true
          else
            args[0] = "-h"
          end
          
        end
        
        # Follow...
        opts.on("-f", "--follow <friends>,<requests>,<sleep>,<who>", Array, "Follow sugarsync and dropbox users: twitter_cli.rb sugarsync_and_dropbox,3,3,<who>") do |lib|
          options[:option_follow] = true
          
          options[:friends]                = lib[0]
          options[:max_number_of_requests] = lib[1]
          options[:sleep_between_requests] = lib[2]
          options[:who]                    = lib[3]
        end
        
        # Unfollow...
        opts.on("-u", "--unfollow <days>,<requests>,<sleep>,<who>", Array, "Unfollow...") do |lib|
          options[:option_unfollow] = true
          
          options[:days]                   = lib[0]
          options[:max_number_of_requests] = lib[1]
          options[:sleep_between_requests] = lib[2]
          options[:who]                    = lib[3]
        end
        
        
        # Account limits
        opts.on("-l", "--limits <who>", Array, "Returns the remaining number of API requests available to the requesting user before the API limit is reached for the current hour" ) do |lib|
          options[:option_limit_status] = true
          options[:who]                 = lib[0]
        end

        # Boolean switch.
        opts.on("-v", "--[no-]verbose", "#Run verbosely") do |v|
          options.verbose = v
        end
        
        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
        
      end
      opts.parse!(args)
      options

    end  # parse()
end
