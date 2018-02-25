module Pageable
  extend ActiveSupport::Concern
  DEFAULT_PER_PAGE = 50
  RESULTS_PER_PAGE = [50, 100]

  included do
    paginates_per DEFAULT_PER_PAGE
    max_paginates_per 500
  end
end