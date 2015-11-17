module Stripable
  extend ActiveSupport::Concern

  included do
    before_validation :strip_strings
  end

  protected

  def strip_strings
    self.as_document.reject! {|k,v| v.strip! if v.is_a?(String)}
  end
end