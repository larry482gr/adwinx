class User < ActiveRecord::Base
  FIRST_NAME = 'first_name'
  LAST_NAME = 'last_name'
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :registerable, :database_authenticatable, :confirmable, :lockable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  serialize :metadata, JSON

  before_save :set_default_metadata

  def set_default_metadata
    if self.metadata.nil?
      self.metadata = []
    else
      self.metadata = self.metadata.split(',')
    end

    self.metadata.unshift(LAST_NAME) unless self.metadata.include? (LAST_NAME)
    self.metadata.unshift(FIRST_NAME) unless self.metadata.include? (FIRST_NAME)
  end
end
