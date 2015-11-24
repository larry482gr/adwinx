class User < ActiveRecord::Base
  FIRST_NAME = 'first_name'
  LAST_NAME = 'last_name'
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :registerable, :database_authenticatable, :confirmable, :lockable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :language

  serialize :metadata, JSON

  private

  after_validation :set_default_metadata

  def set_default_metadata
    meta = self.metadata.blank? ? [] : self.metadata.split(',')

    meta.insert(0, LAST_NAME) unless meta.include? (LAST_NAME)
    meta.insert(1, FIRST_NAME) unless meta.include? (FIRST_NAME)

    self.metadata = meta
  end
end
