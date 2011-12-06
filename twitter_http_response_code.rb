class TwitterHttpResponseCode

    OK_SUCCESS            = '200' # 200 OK: Success!
    NOT_MODIFIED          = '300' # 304 Not Modified: There was no new data to return.
    BAD_REQUEST           = '400' # 400 Bad Request: The request was invalid. An accompanying error message will explain why. This is the status code will be returned during rate limiting.
    UNAUTHORIZED          = '401' # 401 Unauthorized: Authentication credentials were missing or incorrect.
    FORBIDDEN             = '403' # 403 Forbidden: The request is understood, but it has been refused. An accompanying error message will explain why. This code is used when requests are being denied due to update limits.
    NOT_FOUND             = '404' # 404 Not Found: The URI requested is invalid or the resource requested, such as a user, does not exists.
    NOT_ACCEPTABLE        = '406' # 406 Not Acceptable: Returned by the Search API when an invalid format is specified in the request.
    ENHANCE_YOUR_CALM     = '420' # 420 Enhance Your Calm: Returned by the Search and Trends API when you are being rate limited.
    INTERNAL_SERVER_ERROR = '500' # 500 Internal Server Error: Something is broken. Please post to the group so the Twitter team can investigate.
    BAD_GATEWAY           = '502' # 502 Bad Gateway: Twitter is down or being upgraded. 
    SERVICE_UNAVALIBLE    = '503' # 503 Service Unavailable: The Twitter servers are up, but overloaded with requests. Try again later.

  def self.get_code(response_code, response_body)
    
    begin
      response = nil
      #$logger.info "#{self.class.name}.#{__method__}()"
      puts("#{self.class.name}.#{__method__}()")
      case response_code
        when OK_SUCCESS            then
           #$logger.info "response => OK: " + OK_SUCCESS               + " Success!"
           puts("response => OK: " + OK_SUCCESS               + " Success!")
           return JSON.parse(response_body)
        when NOT_MODIFIED          then
           #$logger.error "response => ERROR: " + NOT_MODIFIED          + " Not Modified: There was no new data to return."
           puts("response => ERROR: " + NOT_MODIFIED          + " Not Modified: There was no new data to return.")
           return NOT_MODIFIED
        when BAD_REQUEST           then
           #$logger.error  "response => ERROR: " + BAD_REQUEST           + " Bad Request: The request was invalid. An accompanying error message will explain why. This is the status code will be returned during rate limiting."
           puts("response => ERROR: " + BAD_REQUEST           + " Bad Request: The request was invalid. An accompanying error message will explain why. This is the status code will be returned during rate limiting.")
           return BAD_REQUEST
        when UNAUTHORIZED          then
           #$logger.error  "response => ERROR: " + UNAUTHORIZED          + " Unauthorized: Authentication credentials were missing or incorrect."
           puts("response => ERROR: " + UNAUTHORIZED          + " Unauthorized: Authentication credentials were missing or incorrect.")
           return UNAUTHORIZED
        when FORBIDDEN             then
           #$logger.error  "response => ERROR: " + FORBIDDEN             + " Forbidden: The request is understood, but it has been refused. An accompanying error message will explain why. This code is used when requests are being denied due to update limits."
           puts("response => ERROR: " + FORBIDDEN             + " Forbidden: The request is understood, but it has been refused. An accompanying error message will explain why. This code is used when requests are being denied due to update limits.")
           return FORBIDDEN
        when NOT_FOUND             then
           #$logger.error  "response => ERROR: " + NOT_FOUND             + " Not Found: The URI requested is invalid or the resource requested, such as a user, does not exists."
           puts("response => ERROR: " + NOT_FOUND             + " Not Found: The URI requested is invalid or the resource requested, such as a user, does not exists.")
           return NOT_FOUND
        when NOT_ACCEPTABLE        then
           #$logger.error  "response => ERROR: " + NOT_ACCEPTABLE        + " Not Acceptable: Returned by the Search API when an invalid format is specified in the request."
           puts("response => ERROR: " + NOT_ACCEPTABLE        + " Not Acceptable: Returned by the Search API when an invalid format is specified in the request.")
           return NOT_ACCEPTABLE
        when ENHANCE_YOUR_CALM     then
           #$logger.error  "response => ERROR: " + ENHANCE_YOUR_CALM     + " Enhance Your Calm: Returned by the Search and Trends API when you are being rate limited."
           puts("response => ERROR: " + ENHANCE_YOUR_CALM     + " Enhance Your Calm: Returned by the Search and Trends API when you are being rate limited.")
           return ENHANCE_YOUR_CALM
        when INTERNAL_SERVER_ERROR then
           #$logger.error  "response => ERROR: " + INTERNAL_SERVER_ERROR + " Internal Server Error: Something is broken. Please post to the group so the Twitter team can investigate."
           puts("response => ERROR: " + INTERNAL_SERVER_ERROR + " Internal Server Error: Something is broken. Please post to the group so the Twitter team can investigate.")
           return INTERNAL_SERVER_ERROR
        when BAD_GATEWAY           then
           #$logger.error  "response => ERROR: " + BAD_GATEWAY           + " Bad Gateway: Twitter is down or being upgraded. "
           puts("response => ERROR: " + BAD_GATEWAY           + " Bad Gateway: Twitter is down or being upgraded. ")
           return BAD_GATEWAY
        when SERVICE_UNAVALIBLE    then
           #$logger.error  "response => ERROR: " + SERVICE_UNAVALIBLE    + " Service Unavailable: The Twitter servers are up, but overloaded with requests. Try again later."
           puts("response => ERROR: " + SERVICE_UNAVALIBLE    + " Service Unavailable: The Twitter servers are up, but overloaded with requests. Try again later.")
           return SERVICE_UNAVALIBLE
        else
           #$logger.error  "response => ERROR: " + response_code.to_s
           puts("response => ERROR: " + response_code.to_s)
           return response_code.to_s
      end

    rescue Exception
        #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
        puts("Exception #{self.class.name}.#{__method__}()",($!).class,($!))
        response = nil
    end

    return response
  end
end