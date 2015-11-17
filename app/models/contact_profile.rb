class ContactProfile
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :contact

  private

  before_validation :remove_blank_fields

  def remove_blank_fields
    self.as_document.reject! {|k,v| v.blank?}
  end
end
