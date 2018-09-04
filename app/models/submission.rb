class Submission
  include ActiveModel::Model

  SCREENING_ATTRIBUTES = [ :screening_guidelines, :screening_pii, :screening_funding,
                           :screening_funded_size, :screening_nonfunded_size, :deposit_agreement ]

  SUBMISSION_ATTRIBUTES = [ :title, :creator, :contributor, :affiliation, :contact, :description, :subject,
                            :based_near, :temporal, :language, :format, :related_url, :funding_agency, :grant_number, :doi_exists, :doi, :using_cc0,
                            :license ]

  ATTRIBUTES = SCREENING_ATTRIBUTES + SUBMISSION_ATTRIBUTES

  # Readiness to submit data
  READY = 'ready'
  NOT_READY = 'not ready'

  # Data size
  LESS_THAN_2_5_GB = 'less than 2.5 GB'
  MORE_THAN_2_5_GB = 'more than 2.5 GB'
  LESS_THAN_10_GB = 'less than 10 GB'
  MORE_THAN_10_GB = 'more than 10 GB'

  # Agreement to deposit agreement
  AGREE = 'I agree'
  NOT_AGREE = 'I do not agree'

  # Willingness to use cc0
  USE_CC0 = 'will use cc0'
  NOT_USE_CC0 = 'will not use cc0'

  attr_accessor :submitter, *ATTRIBUTES

  with_options if: :passed_screening? do |completed|
    completed.validates_presence_of :title, :creator, :description, :subject, :doi_exists, :using_cc0
    completed.validates_presence_of :doi, if: :existing_doi?
    completed.validates_presence_of :license, unless: :use_cc0?
  end

  def passed_screening?
    deposit_agreement == AGREE
  end

  private

  def existing_doi?
    doi_exists == 'yes'
  end

  def use_cc0?
    using_cc0 == USE_CC0
  end

end
