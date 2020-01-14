module PrependedPresenters::CollectionPresenter

  delegate :ark, to: :solr_document

  def self.terms
    super.terms + [:ark]
  end

end
