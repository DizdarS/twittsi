class Friend < ActiveRecord::Base

end
class DbHelperFriend
  
  ############
  # Find first
  # This will return the first record matched by the options used.
  # These options can either be specific conditions or merely an order.
  # If no record can be matched, nil is returned.
  def find_by_first(twitter_id)
    begin
      #$logger.info "#{self.class.name}.#{__method__}(#{twitter_id})"
      puts("#{self.class.name}.#{__method__}(#{twitter_id})")
      
      result = Friend.find(:first, :conditions => [ "twitter_id = ?", twitter_id])
      
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
      puts("Result DOES NOT return any record!")
      #$logger.info "Result DOES NOT return any record!"
      result = nil
    end
    return result
  end
  
  ##########
  # Find all
  # This will return all the records matched by the options used.
  # If no records are found, an empty array is returned.
  # http://apidock.com/rails/ActiveRecord/Base/find/class
  def find_all
     begin
      #$logger.info "#{self.class.name}.#{__method__}()"
      puts("#{self.class.name}.#{__method__}()")
      result = Friend.find(:all)
      #result.class.name
      #$logger.info "Result returns array length: #{result.length}"
    rescue Exception
      #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
      puts("Exception #{self.class.name}.#{__method__}()",($!).class,($!))
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
      puts("#{self.class.name}.#{__method__}(#{twitter_id})")
      result = Friend.find(twitter_id)
      #$logger.info "Result returns array length: #{result.length}"
      puts("Result returns array length: #{result.length}")
    rescue ActiveRecord::RecordNotFound
      #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
      puts("#{self.class.name}.#{__method__}()",($!).class,($!))
      #$logger.info "Result returns no records!"
      puts("Result returns no records!")
      result = nil
    end
    return result
  end
  
  ###########################
  # Find first by conditions
  def find_first_by_conditions(twitter_id, is_valid)
    begin
      #$logger.info "#{self.class.name}.#{__method__}(#{twitter_id}, #{is_valid})"
      puts("#{self.class.name}.#{__method__}(#{twitter_id}, #{is_valid})")
      result = Friend.find(:first, :conditions => [ "twitter_id = ? and is_valid = ?", twitter_id, is_valid ])
      if not result.nil?
        #$logger.info "Result returns object: #{result}"
        puts("Result returns object: #{result}")
      else
        #$logger.info "Result DOES NOT return any record!"
        puts("Result DOES NOT return any record!")
      end
    rescue Exception
      #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
      puts("#{self.class.name}.#{__method__}()",($!).class,($!))
      #$logger.info "Result returns no records!"
      puts"Result returns no records!"
      result = nil
    end
    return result
  end
 
  #########
  # create
  # Creates an object (or multiple objects) and saves it to the database, if validations pass.
  # The resulting object is returned whether the object was saved successfully to the database or not.
  def create_or_update_friend(twitter_id, is_valid, comment)
     #is_valid ||= 1
     begin
       #$logger.info  "#{self.class.name}.#{__method__}(#{twitter_id},#{is_valid},#{comment})"
       puts("#{self.class.name}.#{__method__}(#{twitter_id},#{is_valid},#{comment})")
       
       # check if NOT exists
       if find_by_first(twitter_id).nil?
         result = Friend.new(:twitter_id => twitter_id,
                             :is_valid   => is_valid,
                             :comment    => comment)
         result = result.save
         if result == true
           #$logger.info "Friend object is SAVED SUCCESSFULLY! twitter_id => #{twitter_id}"
           puts("Friend object is SAVED SUCCESSFULLY! twitter_id => #{twitter_id}")
         else
           #$logger.error "ERROR Friend object is NOT SAVED! twitter_id => #{twitter_id}"
           puts("ERROR Friend object is NOT SAVED! twitter_id => #{twitter_id}")
         end
         
       elsif not find_first_by_conditions(twitter_id, 0).nil?   # already exist        
         #$logger.info "Friend object already exists: twitter_id => #{twitter_id} and is_valid => 0; Will be updated!"
         puts("Friend object already exists: twitter_id => #{twitter_id} and is_valid => 0; Will be updated!")
         result = update_friend(twitter_id, is_valid, comment)
         
       end

    rescue Exception
      #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
      puts("#{self.class.name}.#{__method__}()",($!).class,($!))
      result = nil
    end
    return result
  end
  
  def update_friend(twitter_id, is_valid, comment)
    is_valid ||= 1
    begin
       #$logger.info  "#{self.class.name}.#{__method__}"
       puts("#{self.class.name}.#{__method__}")
       
       # check if exists
       result = find_first_by_conditions(twitter_id, is_valid)
       if result.nil?
          #$logger.info "Friend object NOT FOUND! twitter_id => #{twitter_id} and is_valid => #{is_valid};"
          puts("Friend object NOT FOUND! twitter_id => #{twitter_id} and is_valid => #{is_valid};")
       else
           result[:is_valid]     = is_valid
           result[:comment]    ||= comment
           result[:updated_at] ||= Date.now
           
           result = result.save
           if result == true
             $logger.info "Friend object is updated! twitter_id => #{twitter_id}"
           else
             $logger.error "ERROR Friend object is NOT UPDATED! twitter_id => #{twitter_id}"
           end
       end
    rescue Exception
      #TwitterUtil.show_error("#{self.class.name}.#{__method__}()",($!).class,($!))
      puts("#{self.class.name}.#{__method__}()",($!).class,($!))
      result = nil
    end
    return result
  end
end