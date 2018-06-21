class Submission
  include ActiveModel::Model

  SCREENING_ATTRIBUTES = [ :screening_guidelines, :screening_pii, :screening_license, :screening_funding,
                           :screening_funded_size, :screening_nonfunded_size, :deposit_agreement ]

  SUBMISSION_ATTRIBUTES = [ :title, :authors, :contributors, :affiliations, :contact_info, :description, :keywords,
                            :geo_areas, :dates, :languages, :formats, :related_materials, :doi_exists, :doi, :using_cco,
                            :cc_license ]

  ATTRIBUTES = SCREENING_ATTRIBUTES + SUBMISSION_ATTRIBUTES

  attr_accessor :submitter, *ATTRIBUTES

end
