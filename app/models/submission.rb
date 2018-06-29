class Submission
  include ActiveModel::Model

  SCREENING_ATTRIBUTES = [ :screening_guidelines, :screening_pii, :screening_license, :screening_funding,
                           :screening_funded_size, :screening_nonfunded_size, :deposit_agreement ]

  SUBMISSION_ATTRIBUTES = [ :title, :authors, :contributors, :affiliations, :contact_info, :description, :keywords,
                            :geo_areas, :dates, :languages, :formats, :related_materials, :doi_exists, :doi, :using_cco,
                            :cc_license ]

  ATTRIBUTES = SCREENING_ATTRIBUTES + SUBMISSION_ATTRIBUTES

  attr_accessor :submitter, *ATTRIBUTES

  with_options if: :passed_screening? do |completed|
    completed.validates_presence_of :title, :authors, :description, :keywords, :doi_exists, :using_cco
    completed.validates_presence_of :doi, if: :existing_doi?
    completed.validates_presence_of :cc_license, unless: :use_cc0?
  end

  def passed_screening?
    deposit_agreement == 'I agree'
  end

  private

  def existing_doi?
    doi_exists == 'yes'
  end

  def use_cc0?
    using_cco == 'will use cc0'
  end

end
