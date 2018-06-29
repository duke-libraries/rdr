class Submission
  include ActiveModel::Model

  SCREENING_ATTRIBUTES = [ :screening_guidelines, :screening_pii, :screening_license, :screening_funding,
                           :screening_funded_size, :screening_nonfunded_size, :deposit_agreement ]

  SUBMISSION_ATTRIBUTES = [ :title, :creator, :contributor, :affiliation, :contact, :description, :keyword,
                            :based_near, :temporal, :language, :format, :related_url, :doi_exists, :doi, :using_cc0,
                            :license ]

  ATTRIBUTES = SCREENING_ATTRIBUTES + SUBMISSION_ATTRIBUTES

  attr_accessor :submitter, *ATTRIBUTES

  with_options if: :passed_screening? do |completed|
    completed.validates_presence_of :title, :creator, :description, :keyword, :doi_exists, :using_cc0
    completed.validates_presence_of :doi, if: :existing_doi?
    completed.validates_presence_of :license, unless: :use_cc0?
  end

  def passed_screening?
    deposit_agreement == 'I agree'
  end

  private

  def existing_doi?
    doi_exists == 'yes'
  end

  def use_cc0?
    using_cc0 == 'will use cc0'
  end

end
