class TwitterInit
  
  CONSUMER_KEY      = ""  # API key
  CONSUMER_SECRET   = ""  # Consumer secret
  ACCESS_TOKEN      = ""  # Access Token (oauth_token)
  ACCESS_SECRET     = ""  # Access Token Secret (oauth_token_secret)
  
  CONSUMER_KEY_1    = ""  # API key
  CONSUMER_SECRET_1 = ""  # Consumer secret
  ACCESS_TOKEN_1    = ""  # Access Token (oauth_token)
  ACCESS_SECRET_1   = ""  # Access Token Secret (oauth_token_secret)
  
  CONSUMER_KEY_2    = ""  # API key
  CONSUMER_SECRET_2 = ""  # Consumer secret
  ACCESS_TOKEN_2    = ""  # Access Token (oauth_token)
  ACCESS_SECRET_2   = ""  # Access Token Secret (oauth_token_secret)
  
  CONSUMER_KEY_3    = ""  # API key
  CONSUMER_SECRET_3 = ""  # Consumer secret
  ACCESS_TOKEN_3    = ""  # Access Token (oauth_token)
  ACCESS_SECRET_3   = ""  # Access Token Secret (oauth_token_secret)
  
  CONSUMER_KEY_4     = ""  # API key
  CONSUMER_SECRET_4  = ""  # Consumer secret
  ACCESS_TOKEN_4     = ""  # Access Token (oauth_token)
  ACCESS_SECRET_4    = ""  # Access Token Secret (oauth_token_secret)
  
  SCREEN_NAME_CLOUDHQ      = 'cloudhq_net'
  SCREEN_NAME_SUGARSYNC    = 'sugarsync'          # 16859110
  SCREEN_NAME_DROPBOX      = 'dropbox'            # 14749606
  SCREEN_NAME_GOOGLEAPPS   = 'googleapps'         # 19367815
  SCREEN_NAME_GOOGLEDOCS   = 'googledocs'         # 32468665
  SCREEN_NAME_BASECAMPNEWS = 'basecampnews'       # 47366813
  SCREEN_NAME_37SIGNALS    = '37signals'          # 11132462
  SCREEN_NAME_LINKEDIN     = 'linkedin'           # 13058772
  SCREEN_NAME_GMAIL        = 'gmail'              # 38679388
  
  USER_ID_SUGARSYNC        = 16859110
  USER_ID_DROPBOX          = 14749606
  USER_ID_GOOGLEAPPS       = 19367815
  USER_ID_GOOGLEDOCS       = 32468665
  USER_ID_BASECAMPNEWS     = 47366813
  USER_ID_37SIGNALS        = 11132462
  USER_ID_LINKEDIN         = 13058772
  USER_ID_GMAIL            = 38679388
  
  OAUTH_SITE                = 'http://api.twitter.com'
  NVITATION_URL_1           = ' http://my.net/?t='
  NVITATION_URL_2           = ' http://my.net/sugarsync/?t='
  NVITATION_URL_3           = ' http://my.net/dropbox/?t='
  DATABASE_YML              = 'twitter_database.yml'
  DATABASE_LOG              = 'twitter_database.log'
  
  URI_API_TWITTER                  = "http://api.twitter.com/1/"
  URI_GET_FOLLOWERS_JSON           = "http://api.twitter.com/1/followers/ids.json?screen_name="
  URI_GET_FRIENDS_JSON             = "http://api.twitter.com/1/friends/ids.json?screen_name="
  URI_GET_USERS_SHOW_BY_ID_JSON    = "http://api.twitter.com/1/users/show.json?user_id="  # 18064965
  URI_GET_USERS_SHOW_BY_NAME_JSON  = "http://api.twitter.com/1/users/show.json?screen_name="
  
  attr_accessor           :access_token
  attr_accessor           :options
  
  attr_accessor           :database_connection
  
  attr_accessor           :followers_cloudhq
  attr_accessor           :friends_cloudhq
  
  attr_accessor           :followers_sugarsync
  attr_accessor           :friends_sugarsync
  
  attr_accessor           :followers_dropbox
  attr_accessor           :friends_dropbox
  
  attr_accessor           :followers_googledocs
  attr_accessor           :friends_googledocs
  
  attr_accessor           :count_bad_gateway_error
  
  attr_accessor           :followers_37signals
  attr_accessor           :friends_37signals

  attr_accessor           :integrations_ids

  def initialize(options)
    @options = options
    puts("@options[:who].upcase = #{@options[:who].upcase}")
    case (@options[:who].upcase)
      when "USER"  : @access_token = get_access_token(ACCESS_TOKEN,   ACCESS_SECRET  , CONSUMER_KEY  , CONSUMER_SECRET  )
      when "USER2" : @access_token = get_access_token(ACCESS_TOKEN_1, ACCESS_SECRET_1, CONSUMER_KEY_1, CONSUMER_SECRET_1)
      when "USER3" : @access_token = get_access_token(ACCESS_TOKEN_2, ACCESS_SECRET_2, CONSUMER_KEY_2, CONSUMER_SECRET_2)
      when "USER4" : @access_token = get_access_token(ACCESS_TOKEN_3, ACCESS_SECRET_3, CONSUMER_KEY_3, CONSUMER_SECRET_3)
      when "USER5" : @access_token = get_access_token(ACCESS_TOKEN_4, ACCESS_SECRET_4, CONSUMER_KEY_4, CONSUMER_SECRET_4)
    else             @access_token = get_access_token(ACCESS_TOKEN,   ACCESS_SECRET  , CONSUMER_KEY  , CONSUMER_SECRET  )
    end
  end
  
  ###############################################################################
  # Exchange your oauth_token and oauth_token_secret for an AccessToken instance.
  ###############################################################################
  def get_access_token(oauth_token, oauth_token_secret, consumer_key, consumer_secret)
    begin
        puts("#{self.class.name}.#{__method__}(#{oauth_token},#{oauth_token_secret})")
        twitter_options = {:site => OAUTH_SITE, :scheme => :header}
        consumer = OAuth::Consumer.new(
                                       consumer_key,                      # API key
                                       consumer_secret,                   # Consumer secret
                                       twitter_options
        )
        # now create the access token object from passed values
        token_hash = { :oauth_token        => oauth_token,       # Access Token (oauth_token)
                       :oauth_token_secret => oauth_token_secret # Access Token Secret (oauth_token_secret)
        }
        access_token = OAuth::AccessToken.from_hash(consumer, token_hash)
        return access_token
    rescue Exception #Twitter::General
        #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
        puts("#{self.class.name}.#{__method__}()",($!).class,($!))
        return nil
    end
    
  end
  
  
end