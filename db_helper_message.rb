
class DbHelperMessage
  
  ##########
  # Find all
  # This will return all the records matched by the options used.
  # If no records are found, an empty array is returned.
  def find_all
     begin
      #$logger.info "#{self.class.name}.#{__method__}()"
      result = Message.find(:all)
      result.class.name
      #$logger.info "Result returns array length: #{result.length}"
    rescue Exception
      #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
      puts("#{self.class.name}.#{__method__}()",($!).class,($!))
      result = nil
    end
    return result
  end
  ################################
  # Find by id
  # This can either be a specific id (1), a list of ids (1, 5, 6), or an array of ids ([5, 6, 10]).
  # If no record can be found for all of the listed ids, then RecordNotFound will be raised.
  def find_by_id(twitter_id)
    begin
      #$logger.info "#{self.class.name}.#{__method__}(#{twitter_id})"
      result = Message.find(twitter_id)
      #$logger.info "Result returns array length: #{result.length}"
    rescue ActiveRecord::RecordNotFound
      #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
      puts("#{self.class.name}.#{__method__}()",($!).class,($!))
      #$logger.info "Result returns no records!"
      result = nil
    end
    return result
  end
  
  ############
  # Find first
  def find_by_first(twitter_id)
    begin
      #$logger.info "#{self.class.name}.#{__method__}(#{twitter_id})"
      result = Message.find(:first, :conditions => [ "twitter_id = ?", twitter_id])
      if not result.nil?
        #$logger.info "Result returns object record: #{result}"
        puts("Result returns object record: #{result}")
      else
        #$logger.info "Result DOES NOT return any record!"
        puts("Result DOES NOT return any record!")
      end
    rescue Exception
      #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
      puts("#{self.class.name}.#{__method__}()",($!).class,($!))
      #$logger.info "Result returns no records!"
      result = nil
    end
    return result
  end
 
  #########
  # create
  # Creates an object (or multiple objects) and saves it to the database, if validations pass.
  # The resulting object is returned whether the object was saved successfully to the database or not.
  def create_message(twitter_id, txt, comment)
     #is_valid ||= 1
     begin
       #$logger.info  "#{self.class.name}.#{__method__}(#{twitter_id},#{txt},#{comment})"
       puts("#{self.class.name}.#{__method__}(#{twitter_id},#{txt},#{comment})")
       
       # check if NOT exists
       if find_by_first(twitter_id).nil?
         result = Message.new(:twitter_id => twitter_id,
                              :message    => txt,
                              :comment    => comment)
         result = result.save
         if result == true
           #$logger.info "Message object is SAVED SUCCESSFULLY! twitter_id => #{twitter_id}"
           puts("Message object is SAVED SUCCESSFULLY! twitter_id => #{twitter_id}")
         else
           #$logger.error "ERROR Message object is NOT SAVED! twitter_id => #{twitter_id}"
           puts("ERROR Message object is NOT SAVED! twitter_id => #{twitter_id}")
         end
       else
         #$logger.warn "WARNING Message object alredy exists! twitter_id => #{twitter_id}"
         puts("WARNING Message object alredy exists! twitter_id => #{twitter_id}")
       end

    rescue Exception
      #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
      puts("#{self.class.name}.#{__method__}()",($!).class,($!))
      result = nil
    end
    return result
  end  
end
