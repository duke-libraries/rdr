class Submission
  include ActiveModel::Model

  attr_accessor :user_key, :screening_guidelines, :screening_pii, :screening_license, :screening_funding, :screening_funded_size, :screening_nonfunded_size, :deposit_agreement, :title, :authors, :contributors, :affiliations, :contact_info, :description, :keywords, :geo_areas, :dates, :languages, :formats, :related_materials, :doi_exists, :doi, :using_cco, :cc_license

end
