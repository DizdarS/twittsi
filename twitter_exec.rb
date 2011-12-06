class TwitterExec
  URI_API_TWITTER                  = "http://api.twitter.com/1/"
  URI_GET_FOLLOWERS_JSON           = "http://api.twitter.com/1/followers/ids.json?screen_name="
  URI_GET_FRIENDS_JSON             = "http://api.twitter.com/1/friends/ids.json?screen_name="
  URI_GET_USERS_SHOW_BY_ID_JSON    = "http://api.twitter.com/1/users/show.json?user_id="  # 18064965
  URI_GET_USERS_SHOW_BY_NAME_JSON  = "http://api.twitter.com/1/users/show.json?screen_name="
  
  USER_ID_SUGARSYNC        = 16859110
  USER_ID_DROPBOX          = 14749606
  USER_ID_GOOGLEAPPS       = 19367815
  USER_ID_GOOGLEDOCS       = 32468665
  USER_ID_BASECAMPNEWS     = 47366813
  USER_ID_37SIGNALS        = 11132462
  USER_ID_LINKEDIN         = 13058772
  USER_ID_GMAIL            = 38679388
  
  NVITATION_URL_1   = ' http://net.net/?t='
  NVITATION_URL_2   = ' http://net.net/sugarsync/?t='
  NVITATION_URL_3   = ' http://net.net/dropbox/?t='
  
  SUGARSYNC_MESSAGE        = "Text? Visit "
  DROPBOX_MESSAGE          = "DText? Visit "
  BASECAMP_MESSAGE         = "Text? Visit "
  GOOGLEDOCS_MESSAGE       = "Do you waTestp? Visit "
  CLOUDHQ_MESSAGE          = "Do you test? Visit "
  
  attr_accessor           :access_token
  attr_accessor           :options
  
  def initialize(options, access_token)
    @access_token = access_token
    @options      = options
  end

  def exec_operation

    if @options[:option_get_info]
      puts ""
    elsif @options[:option_follow]
      puts ""
      option_follow(@options[:friends],
                    @options[:max_number_of_requests],
                    @options[:sleep_between_requests],
                    @options[:who])
    elsif @options[:option_unfollow]
      puts ""
      option_unfollow(@options[:days],
                      @options[:max_number_of_requests],
                      @options[:sleep_between_requests],
                      @options[:who])
    elsif @options[:option_limit_status]
      puts ""
      option_limit_status(@access_token, 'json')
    elsif @options[:sync]
      puts ""
      option_sync_friends()
    elsif @options[:test_friend]
      puts ""
      option_test_friend(@options[:test_twitter_id],
                         @options[:test_is_valid])
    elsif @options[:test_message]
      puts ""
      option_test_message(@options[:test_twitter_id])
    elsif @options[:option_send_message]
      puts ""
      option_send_message(@options[:service],
                          @options[:max_number_of_requests],
                          @options[:sleep_between_requests],
                          @options[:who])
    else
       raise "ERROR: Unsupported operation ==> #{@options}"
    end
  end

  def option_follow(how_we_choose_friends, max_number_of_requests, sleep_between_request, who)
    begin
        #option_get_info()
        #$logger.info "#{self.class.name}.#{__method__}(how_we_choose_friends = #{how_we_choose_friends}, max_number_of_requests = #{max_number_of_requests},sleep_between_request = #{sleep_between_request})"
        puts("#{self.class.name}.#{__method__}(how_we_choose_friends = #{how_we_choose_friends}, max_number_of_requests = #{max_number_of_requests},sleep_between_request = #{sleep_between_request})")
        puts("@access_token=#{@access_token.inspect}")
        twitter_ids = Array.new
        twitter_ids_1 = Array.new
        twitter_ids_2 = Array.new
        twitter_ids_who = Array.new
        cursor = '-1'
        @ids = Array.new
        twitter_ids_who   = tw_get_followers_ids(@access_token,
                                               'json',                                 # json or xml
                                               'screen_name',                          # user_id or screen_name
                                               who,
                                               cursor)
        if (twitter_ids_who.nil?) then twitter_ids_who = [] end
        
        if  (how_we_choose_friends.include?("@")) || (how_we_choose_friends.include?("#"))
          twitter_ids = tw_get_search(@access_token, 'json', how_we_choose_friends, '100', 'mixed', '100','true')
          if (twitter_ids.nil?) then twitter_ids = [] end
        elsif  (how_we_choose_friends.include?("_and_"))  
             # split 
             arr_screen_names = how_we_choose_friends.split(/_and_/)
             puts("======> #{arr_screen_names[0].to_s}")
             @ids = Array.new
             twitter_ids_1   = tw_get_followers_ids(@access_token,
                                                  'json',                                 # json or xml
                                                  'screen_name',                          # user_id or screen_name
                                                   arr_screen_names[0].to_s,
                                                   cursor)
             if (twitter_ids_1.nil?) then twitter_ids_1 = [] end
               
             puts("======> #{arr_screen_names[1].to_s}")
             @ids = Array.new
             twitter_ids_2   = tw_get_followers_ids(@access_token,
                                                   'json',                                 # json or xml
                                                   'screen_name',                          # user_id or screen_name
                                                    arr_screen_names[1].to_s,
                                                    cursor)
                                                    
             if (twitter_ids_2.nil?) then twitter_ids_2 = [] end
                                       
             twitter_ids = (twitter_ids_1 & twitter_ids_2) - twitter_ids_who
             
        else
             ##################
             # Example Request
             # GET https://api.twitter.com/1/followers/ids.json?cursor=-1&screen_name=twitterapi
             @ids = Array.new
             twitter_ids_1   = tw_get_followers_ids(@access_token,  
                                                     'json',                                 # json or xml
                                                     'screen_name',                          # user_id or screen_name
                                                     how_we_choose_friends,
                                                     cursor)
             if (twitter_ids_1.nil?) then twitter_ids_1 = [] end
             twitter_ids = twitter_ids_1 - twitter_ids_who 
             puts("#{how_we_choose_friends} => #{twitter_ids_1.length}")
             puts("#{who} => #{twitter_ids_who.length}")  
             puts("=> #{twitter_ids.length}")    
        end
        
        # make some follow optimization
        db_helper_friend = DbHelperFriend.new
        all_friends = db_helper_friend.find_all
        friends_ids = Array.new         # we already followed these users
        
        all_friends.each do |friend|
          friends_ids << friend[:twitter_id] # twitter_id
        end
        #$logger.info " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! friends_ids.length = #{friends_ids.length} !!!!!!!!!!!!!!!!!"
        puts("twitter_ids.length = #{twitter_ids.length}")
        puts("friends_ids.length = #{friends_ids.length}")
        twitter_ids = twitter_ids - friends_ids
 
        if twitter_ids.length > 0
            #$logger.info "#{how_we_choose_friends}: #{twitter_ids.length}"
            puts("#{how_we_choose_friends}: #{twitter_ids.length}")
        else
            puts("=====> No data =====>#{twitter_ids.inspect}")
        end

        i=0
        k=0

        twitter_ids.each do |twitter_id|
          if i < max_number_of_requests.to_i
                ###################################################################################
                #$logger.info "###################################################################################"

                db_helper_friend = DbHelperFriend.new
                obj = db_helper_friend.find_by_first(twitter_id)
                if obj.nil?
                  response = tw_post_friendship_create(@access_token, 'json', 'user_id', twitter_id)
                  if response == TwitterHttpResponseCode::OK_SUCCESS
                    is_valid = 1
                    db_helper_friend.create_or_update_friend(twitter_id, is_valid, how_we_choose_friends)

                    sec = rand(sleep_between_request)
                    i+=1
                    #$logger.info "#{i}. friendship created! twitter_id = #{twitter_id}. Sleep #{sec} seconds!"
                    puts "#{i}. friendship created! twitter_id = #{twitter_id}. Sleep #{sec} seconds!"
                    sleep(sec)

                  elsif response == TwitterHttpResponseCode::FORBIDDEN
                    k+=1
                    #$logger.warn "#{k}. FORBIDDEN: Friendship is NOT created and NOT saved in database! ==> Enough for today! => OR Tweets are protected. Only confirmed followers have access to ..."
                    if k == 40
                     i = max_number_of_requests.to_i
                    end
                  elsif response == TwitterHttpResponseCode::UNAUTHORIZED
                    i = max_number_of_requests.to_i
                  end
                end
          end

        end

      rescue Exception
          #TwitterInit.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
          puts("#{self.class.name}.#{__method__}()",($!).class,($!))
          return nil
      end
  end

  def option_unfollow(days, max_number_of_requests, sleep_between_request, who)
    begin
      #$logger.info "#{self.class.name}.#{__method__}(days = #{days}, max_number_of_requests = #{max_number_of_requests},sleep_between_request = #{sleep_between_request})"
      puts("#{self.class.name}.#{__method__}(days = #{days}, max_number_of_requests = #{max_number_of_requests},sleep_between_request = #{sleep_between_request})")
      cursor = '-1'
      i=0
      @ids = Array.new
      friends = tw_get_friends_ids(@access_token,
                                  'json',                                 # json or xmls
                                  'screen_name',                          # user_id or screen_name
                                   who,
                                   cursor)
      @ids = Array.new
      followers = tw_get_followers_ids(@access_token,
                                      'json',                             # json or xml
                                      'screen_name',                      # user_id or screen_name
                                      who,
                                      cursor)
      ids_diff = Array.new
      puts("-------------->>>>>>>>>>>>")
      puts("friends.inspect = #{friends.inspect}")
      ids_diff = friends - followers
      
      @integrations_ids = [USER_ID_SUGARSYNC,
                           USER_ID_DROPBOX,
                           USER_ID_GOOGLEAPPS,
                           USER_ID_GOOGLEDOCS,
                           USER_ID_BASECAMPNEWS,
                           USER_ID_37SIGNALS,
                           USER_ID_GMAIL]

      # A whitelist or approved list is a list or register of entities that, for one reason or another,
      # are being provided a particular privilege, service, mobility, access or recognition.
      lines = File.readlines('whitelist.txt')
      whitelist_twitter_ids = Array.new
      lines.each do |line|
        line = line.strip()
        if line[0,1] != "#"  # don’t read comment - escape it
          whitelist_twitter_ids << line.to_i
          #$logger.info "#{self.class.name} => whitelist_twitter_ids << #{line}"
        end
      end
      #
      @dont_unfollow_twitter_ids = whitelist_twitter_ids + @integrations_ids
      
      ids      = ids_diff         - @dont_unfollow_twitter_ids      #@integrations_ids
      #$logger.info "ids = @friends_cloudhq - @followers_cloudhq = #{ids}"
      if ids.length > 0
        #$logger.info "Number of users who are not following back: #{ids.length}"
        ids.each do |twitter_id|
          if i < max_number_of_requests.to_i
            friend_helper = DbHelperFriend.new
            friend = friend_helper.find_by_first(twitter_id)
            date_until = Time.now - days.to_i.days
            if ((not friend.nil?) && (date_until > friend["created_at"])) ||     # users whom we sent following request and they dont followeing us
                (friend.nil?)                                                    # users that unfollow us
                r = tw_post_friendship_destroy(@access_token,
                                              'json',         # json or xml
                                              'user_id',      # user_id or screen_name
                                              twitter_id)
                if r == TwitterHttpResponseCode::OK_SUCCESS
                  sec = rand(sleep_between_request)
                  #$logger.info "#{i}. friendship destroyed! twitter_id = #{twitter_id}. Sleep #{sec} seconds!"
                  puts("#{i}. friendship destroyed! twitter_id = #{twitter_id}. Sleep #{sec} seconds!")
                  sleep(sec)
                  i+=1
                  if not friend.nil?
                    friend["is_valid"] = 0
                    friend.save
                  end
                end
            end
          end
        end
      else
        #$logger.info "Number of users who are not following back = 0!"
        puts("Number of users who are not following back = 0!")
      end

    rescue Exception
        #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
        puts("#{self.class.name}.#{__method__}()",($!).class,($!))
        return nil
    end

  end
  
  def option_send_message(message_type, max_number_of_requests, sleep_between_request, who)

    #$logger.info "#{self.class.name}.#{__method__}()"
    #$logger.info "#{url}"
    puts("#{self.class.name}.#{__method__}()")
    i = 0
    k = 0
    
    message_type = DROPBOX_MESSAGE
    url          = NVITATION_URL_3
    comment      = "Intersection cloudHQ_net & Dropbox"

    message = help_random_message(message_type)
    
    ##################
    # Example Request
    # GET https://api.twitter.com/1/followers/ids.json?cursor=-1&screen_name=twitterapi
    cursor ='-1'
    @ids = Array.new
    twitter_ids   = tw_get_followers_ids(@access_token,
                                         'json',                                 # json or xml
                                         'screen_name',                          # user_id or screen_name
                                         who,
                                         cursor)
    begin
      if twitter_ids.length > 0
        twitter_ids.each do |twitter_id|
          if i < max_number_of_requests.to_i
            message = help_random_message(message_type)
            txt = message + url + twitter_id.to_s
            ##########################
            # POST direct_messages/new
            ##########################
            message_helper = DbHelperMessage.new
            obj = message_helper.find_by_first(twitter_id)
            if obj.nil? #We send a message only if object does not exist in tabel
              direct_message = tw_post_direct_message(@access_token, 'json', 'user_id', twitter_id, txt)

              if direct_message == TwitterHttpResponseCode::OK_SUCCESS
                # Save to database
                message_helper.create_message(twitter_id, txt, comment)
                i+=1
                sec = rand(sleep_between_request)
                sleep(sec)
                #$logger.info "#{i}.Message is sent. Sleept #{sec} sec."
                puts("#{i}.Message is sent. Sleept #{sec} sec.")
              elsif direct_message == TwitterHttpResponseCode::FORBIDDEN
                k+=1
                #$logger.warn "#{k}. FORBIDDEN: Messsage is NOT sent and NOT saved in database! ==> Enough for today!"
                puts("#{k}. FORBIDDEN: Messsage is NOT sent and NOT saved in database! ==> Enough for today!")
                if k==40
                  i = max_number_of_requests.to_i
                  sleep 2
                end
              end
            end
          end
        end
      else
       #$logger.warn "Array twitter_ids is empty! Nothing to do!"
       puts("Array twitter_ids is empty! Nothing to do!")
      end
    rescue Exception
      #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
      puts("#{self.class.name}.#{__method__}()",($!).class,($!))
      return nil
    end
  end 
  
                      ########################
                       #  Account Resources   #
                       ########################
  
  ##################################################################################
  # GET account/rate_limit_status
  # Returns the remaining number of API requests available to the requesting user
  # before the API limit is reached for the current hour. 
  # Calls to rate_limit_status do not count against the rate limit.
  # If authentication credentials are provided, the rate limit status for the
  # authenticating user is returned. 
  ##################################################################################

  def option_limit_status(access_token,
                          format         # json or xml
                          )
    puts "option_get_account_rate_limit_status ===> START"
    uri = URI_API_TWITTER                     +
          'account/rate_limit_status'         + "." +
          format

    begin
      puts "get_account_rate_limit_status => " + uri
      response = access_token.request(:get, uri)
      puts response.body
      response = TwitterHttpResponseCode.get_code(response.code, response.body)
      
    rescue Exception
        #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
        puts("#{self.class.name}.#{__method__}()",($!).class,($!))
        response = nil
    end
    
    return response

  end
  
  
                          #############################
                          # GET search                #
                          #############################
    ###################################################################################
    # GET search                                                                      #
    # Returns tweets that match a specified query.                                    #
    # http://search.twitter.com/search.format                                         #
    # Search query. Should be URL encoded. Queries will be limited by complexity.     #
    # http://search.twitter.com/search.json?q=Twitter%20API&result_type=mixed&count=5 #
    # https://dev.twitter.com/docs/api/1/get/search                                   #
    ###################################################################################
    def tw_get_search(access_token,
                      format,                                  # json or xml
                      query,
                      rpp,                                     # The number of tweets to return per page, up to a max of 100.
                      result_type,
                      count,
                      show_user
                     )
      uri = 'http://search.twitter.com/'                +
            'search'                                    + "." +
            format                                      + "?" +
            'q'                                         + "=" +
            CGI.escape(query)                           + "&" +
            'rpp'                                       + "=" +
            rpp                                         + "&" +
            'result_type'                               + "=" +
            result_type                                 + "&" +
            'count'                                     + "=" +
            count                                       + "&" +
            'show_user'                                 + "=" +
            show_user
      begin
        #$logger.info "#{self.class.name}.#{__method__}(#{query}, ... )"
        #$logger.info "#{uri}"
        puts("#{self.class.name}.#{__method__}(#{query}, ... )")

        response = access_token.request(:get, uri)

        r = TwitterHttpResponseCode.get_code(response.code, response.body)

        if response.code == TwitterHttpResponseCode::OK_SUCCESS
          #$logger.info "Returns the authenticated user's saved search queries => SUCCESSFULLY!"
          puts("Returns the authenticated user's saved search queries => SUCCESSFULLY!")

          parsed_json = ActiveSupport::JSON.decode(response.body)

          twitter_ids = Array.new
          parsed_json["results"].each do |result|
            puts result["from_user"] + " " + result["from_user_id_str"].to_s               #result["from_user_id_str"]
            twitter_user = tw_get_users_show(@access_token, 'json', 'screen_name', result["from_user"])
            puts twitter_user["id_str"].to_s
            twitter_ids << twitter_user["id_str"]
          end

          #$logger.info "response.body =>#{response.body}"
        end

        return twitter_ids

      rescue Exception
        #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
        puts("#{self.class.name}.#{__method__}()",($!).class,($!))
        return nil
      end
    end

    ###################################################################################
    # GET followers/ids
    # Returns an array of numeric IDs for every user following the specified user.
    # Example Request
    # GET https://api.twitter.com/1/followers/ids.json?cursor=-1&screen_name=twitterapi
    ###################################################################################
    def tw_get_followers_ids(access_token,
                             format,                                 # json or xml
                             parameters,                             # user_id or screen_name
                             user_for_whom_to_return_results_for,
                             cursor)
                
      uri = URI_API_TWITTER                          +
            "followers/ids"                          + "." +
            format                                   + "?" +
            parameters                               + "=" +  
            user_for_whom_to_return_results_for.to_s + "&" +
            "cursor"                                 + "=" +
            cursor
      
      @ids ||= Array.new
      @count_bad_gateway_error ||= 0
      
      begin
        #$logger.info "#{self.class.name}.#{__method__}(#{user_for_whom_to_return_results_for})"
        puts("#{self.class.name}.#{__method__}(#{user_for_whom_to_return_results_for})")
        #$logger.info "#{uri}"
        puts("#{uri}")

        response = access_token.request(:get, uri)
        
        r = TwitterHttpResponseCode.get_code(response.code, response.body)
        
        if response.code == TwitterHttpResponseCode::OK_SUCCESS
          #$logger.info "Number of followers: #{r.length}"
          puts("........ OK .........")
        elsif response.code == TwitterHttpResponseCode::BAD_GATEWAY
          if (@count_bad_gateway_error.to_i<5)
            #puts "@count_bad_gateway_error =" + @count_bad_gateway_error.to_s
            @count_bad_gateway_error+=1
            sleep 1
            #$logger.info "count_bad_gateway_error = #{@count_bad_gateway_error}"
            puts("count_bad_gateway_error = #{@count_bad_gateway_error}")
            
            r = self.tw_get_followers_ids(access_token,
                                          format,                                 # json or xml
                                          parameters,                             # user_id or screen_name
                                          user_for_whom_to_return_results_for,
                                          cursor)            
          end
        else
          return nil
        end
        
        @count_bad_gateway_error = 0
        
        r = ActiveSupport::JSON.decode(response.body) 
        r["ids"].each do |id|
          @ids << id
        end
        
        puts("r['next_cursor']=====================>#{r['next_cursor']}")
        puts("r['previous_cursor']=================>#{r['previous_cursor']}")
        puts("@ids.length=#{@ids.length}")
        
        if r['next_cursor'] > 0
          cursor = r['next_cursor'].to_s
          puts("---------------------------------------------------------")
          self.tw_get_followers_ids(access_token,
                                    format,                                 # json or xml
                                    parameters,                             # user_id or screen_name
                                    user_for_whom_to_return_results_for,
                                    cursor)
        end
        #@ids.each do |id|
         # puts("id=#{id}")
        #end
        return @ids
      rescue Exception
          #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
          puts("#{self.class.name}.#{__method__}()",($!).class,($!))
          r = nil
      end
    end

                         ##################
                         # User Resources #
                         ##################

    ####################################################################
    # GET users/show
    # Returns extended information of a given user,
    # specified by ID or screen name as per the required id parameter.
    # The author's most recent status will be returned inline.
    ####################################################################
    def tw_get_users_show(access_token,
                          format,                                 # json or xml
                          parameters,                             # user_id or screen_name
                          user_whom_to_return_results_for)        # The ID of the user for whom to return results for.

      uri = URI_API_TWITTER                      +
            'users/show'                         + "." +
            format                               + "?" +
            parameters                           + "=" +
            user_whom_to_return_results_for.to_s
      begin
        puts "get_users_show => " + uri
        response = access_token.request(:get, uri)
        response = TwitterHttpResponseCode.get_code(response.code, response.body)
      rescue Exception
          #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
          puts("#{self.class.name}.#{__method__}()",($!).class,($!))
          response = nil
      end
      return response

    end
    
    
                         ###################################
                         # Friends and Followers Resources #
                         ###################################

    ###################################################################################
    # GET friends/ids
    # Returns an array of numeric IDs for every user the specified user is following.
    # http://api.twitter.com/1/friends/ids.json?user_id=12345
    ###################################################################################
    def tw_get_friends_ids(access_token,
                           format,                                 # json or xmls
                           parameters,                             # user_id or screen_name
                           user_for_whom_to_return_results_for,
                           cursor)
      uri = URI_API_TWITTER                          +
            "friends/ids"                            + "." +
            format                                   + "?" +
            parameters                               + "=" +
            user_for_whom_to_return_results_for.to_s + "&" +
            "cursor"                                 + "=" +
            cursor
      @ids ||= Array.new
      begin
        #$logger.info "#{self.class.name}.#{__method__}(#{user_for_whom_to_return_results_for})"
        #$logger.info "#{uri}"
        puts("#{self.class.name}.#{__method__}(#{user_for_whom_to_return_results_for})")
        puts("#{uri}")
        
        response = access_token.request(:get, uri)
        
        r = TwitterHttpResponseCode.get_code(response.code, response.body)
        
        if response.code == TwitterHttpResponseCode::OK_SUCCESS
          #$logger.info "Number of friends: " "#{r.length}"
          puts("Number of friends: " "#{r.length}")
        else
          return nil
        end
        r = ActiveSupport::JSON.decode(response.body) 
        r["ids"].each do |id|
            @ids << id
        end
        if r['next_cursor'] > 0
          cursor = r['next_cursor'].to_s
          puts("---------------------------------------------------------")
          self.tw_get_friends_ids(access_token,
                                 format,                                 # json or xml
                                 parameters,                             # user_id or screen_name
                                 user_for_whom_to_return_results_for,
                                 cursor)
        end
        return @ids
      rescue Exception #Twitter::General
          #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
          puts("#{self.class.name}.#{__method__}()",($!).class,($!))
          return nil
      end

    end
                         ########################
                         # Friendship Resources #
                         ########################

    ##################################################################################
    # POST friendships/create
    # Allows the authenticating users to follow the user specified in the ID parameter.
    # Returns the befriended user in the requested format when successful.
    # Returns a string describing the failure condition when unsuccessful.
    # If you are already friends with the user an HTTP 403 will be returned.
    ##################################################################################
    def tw_post_friendship_create(access_token,
                                  format,                         # json or xml
                                  parameters,                     # user_id or screen_name
                                  user_whom_to_return_results_for)
                            #   prameter_follow)                 # Enable notifications for the target user.

      uri = URI_API_TWITTER                      +
            'friendships/create'                 + "."        +
            format                               + "?"        +
            parameters                           + "="        +
            user_whom_to_return_results_for.to_s #+ "&follow=" +
            #prameter_follow
      begin
        #$logger.info "#{self.class.name}.#{__method__}(#{user_whom_to_return_results_for})"
        #puts("#{self.class.name}.#{__method__}(#{user_whom_to_return_results_for})")
        puts "#{uri}"
        response = access_token.request(:post, uri)
        r = TwitterHttpResponseCode.get_code(response.code, response.body)

        if response.code == TwitterHttpResponseCode::OK_SUCCESS
          #$logger.info "We have a new friend, twitter_id = #{user_whom_to_return_results_for}"
          puts("We have a new friend, twitter_id = #{user_whom_to_return_results_for}")
        end

        return response.code

      rescue Exception
          #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
          puts("#{self.class.name}.#{__method__}()",($!).class,($!))
          return nil
      end

    end
    
    ####################################################################################
    # POST friendships/destroy
    # Allows the authenticating users to unfollow the user specified in the ID parameter.
    # Returns the unfollowed user in the requested format when successful.
    # Returns a string describing the failure condition when unsuccessful.
    #####################################################################################
    def tw_post_friendship_destroy(access_token,
                                   format,                         # json or xml
                                   parameters,                     # user_id or screen_name
                                   user_whom_to_return_results_for)

      uri = URI_API_TWITTER                      +
            'friendships/destroy'                + "."        +
            format                               + "?"        +
            parameters                           + "="        +
            user_whom_to_return_results_for.to_s
      begin
        #$logger.info "#{self.class.name}.#{__method__}(#{user_whom_to_return_results_for})"
        puts "#{uri}"
        response = access_token.request(:post, uri)
        r = TwitterHttpResponseCode.get_code(response.code, response.body)

        if response.code == TwitterHttpResponseCode::OK_SUCCESS
          #$logger.info "Friend is UNFOLLOWED SUCCESSFULLY, twitter_id = #{user_whom_to_return_results_for}"
          puts("Friend is UNFOLLOWED SUCCESSFULLY, twitter_id = #{user_whom_to_return_results_for}")
        end

        return response.code

      rescue Exception
          #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
          puts("#{self.class.name}.#{__method__}()",($!).class,($!))
          return nil
      end
    end

                         #############################
                         # Direct Messages Resources #
                         #############################

    ################################################################################
    # POST direct_messages/new
    # Sends a new direct message to the specified user from the authenticating user.
    # Requires both the user and text parameters and must be a POST.
    # Returns the sent message in the requested format if successful.
    ################################################################################
    def tw_post_direct_message(access_token,
                               format,                                 # json or xml
                               parameters,                             # user_id or screen_name
                               user_who_should_receive_direct_message, # The ID of the user who should receive the direct message.
                               text)
      uri = URI_API_TWITTER                             +
            'direct_messages/new'                       + "." +
            format                                      + "?" +
            parameters                                  + "=" +
            user_who_should_receive_direct_message.to_s + "&text=" +
            CGI.escape(text)
      begin
        #$logger.info "#{self.class.name}.#{__method__}(#{user_who_should_receive_direct_message}, #{text} )"
        #$logger.info "#{uri}"
        puts("#{self.class.name}.#{__method__}(#{user_who_should_receive_direct_message}, #{text} )")
        puts("#{uri}")

        response = access_token.request(:post, uri)
        r = TwitterHttpResponseCode.get_code(response.code, response.body)

        if response.code == TwitterHttpResponseCode::OK_SUCCESS
          #$logger.info "Message is SENT SUCCESSFULLY to twitter_id = #{user_who_should_receive_direct_message}"
          puts("Message is SENT SUCCESSFULLY to twitter_id = #{user_who_should_receive_direct_message}")
        end

        return response.code

      rescue Exception
        #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
        puts("#{self.class.name}.#{__method__}()",($!).class,($!))
        return nil
      end
    end

    def help_random_message(message_type)
      begin
        if message_type == SUGARSYNC_MESSAGE
          random_messages_sugar_sync = ["cloudHQ integrates SugarSync and GoogleDocs. Please visit ",
                                        "cloudHQ integrates GoogleDocs and SugarSync. Please visit ",

                                        "With cloudHQ you can edit SugarSync documents from GoogleDocs! ",
                                        "Get all your GoogleDocs documents into SugarSync! Visit ",

                                        "cloudHQ synchronizes GoogleDocs with SugarSync. Visit ",
                                        "cloudHQ synchronizes SugarSync with GoogleDocs. Visit ",

                                        "cloudHQ can synchronize SugarSync documents with GoogleDocs! Visit ",
                                        "cloudHQ integrates SugarSync documents with GoogleDocs! Visit ",

                                        "Synchronize GoogleDocs and SugarSync easily with cloudHQ. Visit ",
                                        "Synchronize SugarSync and GoogleDocs easily with cloudHQ. Visit "]
          r = rand(random_messages_sugar_sync.length) # Random message should be sent!
          message = random_messages_sugar_sync[r]
          return message
        end

        if message_type == DROPBOX_MESSAGE
          random_messages_sugar_sync =["cloudHQ integrates Basecamp, Dropbox and GoogleDocs. Please visit ",
                                       "cloudHQ integrates Basecamp, GoogleDocs and Dropbox. Please visit ",

                                       "cloudHQ replicates Basecamp, Dropbox and GoogleDocs. Please visit ",
                                       "cloudHQ replicates Basecamp, GoogleDocs and Dropbox. Please visit ",

                                       "With cloudHQ you can edit Basecamp or Dropbox files from GoogleDocs! ",
                                       "Get all your GoogleDocs & Basecamp project into Dropbox! Visit ",

                                       "cloudHQ synchronizes GoogleDocs with Basecamp and Dropbox. Visit ",
                                       "cloudHQ synchronizes Basecamp, Dropbox with GoogleDocs. Visit ",

                                       "cloudHQ syncs GoogleDocs with Basecamp and Dropbox. Visit ",
                                       "cloudHQ syncs Basecamp, Dropbox with GoogleDocs. Visit ",

                                       "cloudHQ can synchronize Basecamp, Dropbox documents with GoogleDocs! Visit ",
                                       "cloudHQ can sync Basecamp, Dropbox documents with GoogleDocs! Visit ",

                                       "cloudHQ integrates Basecamp, Dropbox documents with GoogleDocs! Visit ",

                                       "Synchronize Basecamp, GoogleDocs and Dropbox easily with cloudHQ. Visit ",
                                       "Synchronize Basecamp, Dropbox and GoogleDocs easily with cloudHQ. Visit ",

                                       "Sync Basecamp, GoogleDocs and Dropbox easily with cloudHQ. Visit ",
                                       "Sync Basecamp, Dropbox and GoogleDocs easily with cloudHQ. Visit "]
                                      #123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890#
                                      #--------10--------20--------30--------40--------50--------60--------70--------80--------90#
          r = rand(random_messages_sugar_sync.length) # Random message should be sent!
          message = random_messages_sugar_sync[r]
          return message
        end

        if message_type == BASECAMP_MESSAGE
          random_messages_sugar_sync = ["Integrate Basecamp and GoogleDocs! Visit ",
                                        "Integrate GoogleDocs and Basecamp! Visit ",

                                        "Manage your Basecamp attachmnets from GoogleDocs! Visit ",
                                        "Edit your Basecamp attachmnets from a GoogleDocs interface! Visit ",

                                        "cloudHQ is integration of GoogleDocs and Dropbox with Basecamp! ",
                                        "cloudHQ integrates of GoogleDocs and Dropbox with Basecamp. ",

                                        "cloudHQ will synchronize SugarSync or Dropbox, Basecamp, and GoogleDocs! ",
                                        #12345678901234567890123456789012345678901234567890123456789012345678901234567890123
                                        "Synchronize SugarSync, Dropbox, Basecamp, & GoogleDocs!  Visit ",

                                        "Synchronize Basecamp projects with GoogleDocs & Dropbox easily with cloudHQ! Visit ",
                                        "Synchronize Basecamp projects with Dropbox & GoogleDocs easily with cloudHQ! Visit "]
          r = rand(random_messages_sugar_sync.length) # Random message should be sent!
          message = random_messages_sugar_sync[r]
          return message
        end

        if message_type == GOOGLEDOCS_MESSAGE
          random_messages_sugar_sync = ["cloudHQ integrates Basecamp, Dropbox/SugarSync with GoogleDocs. Visit ",
                                        "cloudHQ integrates GoogleDocs with Basecamp, Dropbox or SugarSync. Please visit ",

                                        "With cloudHQ you can edit Basecamp, Dropbox/SugarSync docs using GoogleDocs! ",
                                        "Get all your GoogleDocs documents into Basecamp or Dropbox or SugarSync! Visit ",

                                        "cloudHQ synchronizes GoogleDocs with Basecamp, Dropbox/SugarSync. Visit ",
                                        "cloudHQ synchronizes Basecamp, Dropbox or SugarSync with GoogleDocs. Visit ",

                                        "cloudHQ can synchronize Basecamp, Dropbox/SugarSync with GoogleDocs! ",
                                        "cloudHQ integrates Basecamp, Dropbox or SugarSync with GoogleDocs! Visit ",

                                        "Synchronize GoogleDocs and Basecamp, Dropbox/SugarSync using cloudHQ. Visit ",
                                        "Synchronize Dropbox/SugarSync, Basecamp and GoogleDocs easily with cloudHQ. Visit "]
          r = rand(random_messages_sugar_sync.length) # Random message should be sent!
          message = random_messages_sugar_sync[r]
          return message
        end

        if message_type == CLOUDHQ_MESSAGE
          random_messages_sugar_sync = ["cloudHQ integrates Basecamp, Dropbox, SugarSync and GoogleDocs. Visit ",
                                        "cloudHQ integrates GoogleDocs and Basecamp, Dropbox or SugarSync. Please visit ",

                                        "With cloudHQ you can edit Basecamp, Dropbox, SugarSync docs from GoogleDocs! ",
                                        "Get all your GoogleDocs documents into Basecamp, Dropbox or SugarSync! Visit ",

                                        "cloudHQ synchronizes GoogleDocs with Basecamp, Dropbox/SugarSync. Visit ",
                                        "cloudHQ synchronizes Basecamp, Dropbox/SugarSync with GoogleDocs. Visit ",

                                        "cloudHQ can synchronize Basecamp, Dropbox or SugarSync with GoogleDocs! ",
                                        "cloudHQ integrates Basecamp, Dropbox/SugarSync with GoogleDocs! Visit ",

                                        "Synchronize GoogleDocs, Basecamp, Dropbox/SugarSync using cloudHQ. Visit ",
                                        "Synchronize Basecamp, Dropbox/SugarSync and GoogleDocs easily with cloudHQ. Visit "]
                                        #123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890#
                                        #--------10--------20--------30--------40--------50--------60--------70--------80--------90#
          r = rand(random_messages_sugar_sync.length) # Random message should be sent!
          message = random_messages_sugar_sync[r]
          return message
        end


      rescue Exception
          #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
          puts("#{self.class.name}.#{__method__}()",($!).class,($!))
          return nil
      end
    end

end