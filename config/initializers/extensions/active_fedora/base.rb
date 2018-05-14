ActiveFedora::Base.class_eval do

  def self.find_by_ark(ark)
    results = ActiveFedora::Base.where(Rdr::Index::Fields.ark => ark)
    case
    when results.count == 1
      results.first
    when results.count == 0
      raise Rdr::NotFoundError, I18n.t('rdr.not_found', target: ark)
    else
      raise Rdr::UnexpectedMultipleResultsError, I18n.t('rdr.unexpected_multiple_results', identifier: ark)
    end
  end

end
