require 'uri'

class SmsMessage < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :sqlbox

  include NullifyBlankAttributes

  def proper_id
    query = "SELECT id
             FROM #{self.class.table_name}
  			     WHERE sql_id = #{self.sql_id}"

    result = self.class.connection.exec_query(query)

    return result.to_hash[0]['id']
  end

  protected

  # Moved to SmsCampaign
  # before_create :msg_url_encode
  before_create :generate_random_id

  # Moved to SmsCampaign
  # def msg_url_encode
  #   self.msgdata = URI.encode(self.msgdata) unless self.msgdata.blank?
  # end

  def generate_random_id
    random_id = ''
    10.times do
      random_id << rand(0..9).to_s
    end

    self.msg_id = random_id

    #query = "UPDATE #{self.class.table_name}
  	#		 SET msg_id = #{random_id}
  	#		 WHERE sql_id = #{self.sql_id}"

    #self.class.connection.execute(query)
  end
end
