class Language < ActiveRecord::Base
  has_many :users

  validates :language, presence: true
  validates :locale, presence: true, uniqueness: true

  def option_label
    self.language.capitalize
  end
end
