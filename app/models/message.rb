require 'uri'

class Message < ActiveRecord::Base
  self.abstract_class = true

  establish_connection :sqlbox
  # self.table_name = 'send_sms'
  self.primary_key = 'sql_id'

  include NullifyBlankAttributes

  def proper_id
    query = "SELECT id
             FROM #{self.class.table_name}
  			     WHERE sql_id = #{self.sql_id}"

    result = self.class.connection.exec_query(query)

    return result.to_hash[0]['id']
  end

  protected

  before_create :msg_url_encode
  after_create :generate_random_id

  def msg_url_encode
    self.msgdata = URI.encode(self.msgdata) unless self.msgdata.nil?
  end

  def generate_random_id
    random_id = ''
    10.times do
      random_id << rand(0..9).to_s
    end

    query = "UPDATE #{self.class.table_name}
  			 SET id = #{random_id}
  			 WHERE sql_id = #{self.sql_id}"

    self.class.connection.execute(query)
  end
end
