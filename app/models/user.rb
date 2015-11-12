class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :registerable, :database_authenticatable, :confirmable, :lockable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

end
