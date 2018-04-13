class AssignDoi

  DOI_PREFIX = '10.7924'

  attr_accessor :work

  def self.call(work)
    new(work).assign!
  end

  def initialize(work)
    @work = work
  end

  def assign!
    if work.doi_assignable?
      ark_suffix = work.ark.split('/').last
      doi = [ DOI_PREFIX, ark_suffix ].join("/")
      work.doi = doi
      unless work.save
        raise Rdr::DoiAssignmentError, I18n.t('rdr.doi.assignment_failed')
      end
    else
      raise Rdr::DoiAssignmentError, I18n.t('rdr.doi.not_assignable')
    end
  end

end
