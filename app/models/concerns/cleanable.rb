module Cleanable
  extend ActiveSupport::Concern

  included do
    before_validation :remove_blank_fields
  end

  protected

  def remove_blank_fields
    self.as_document.reject! {|k,v| v.blank?}
  end
end