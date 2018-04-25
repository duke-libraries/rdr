# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension( Hydra::ContentNegotiation )

  include Rdr::DatasetVersioning

  def affiliation
    self[Rdr::Index::Fields.affiliation]
  end

  def alternative
    self[Rdr::Index::Fields.alternative]
  end

  def ark
    self[Rdr::Index::Fields.ark]
  end

  def available
    self[Rdr::Index::Fields.available]
  end

  def based_near
    self[Rdr::Index::Fields.based_near]
  end

  def bibliographic_citation
    self[Rdr::Index::Fields.bibliographic_citation]
  end

  def doi
    self[Rdr::Index::Fields.doi]
  end

  def doi_assignable?
    ark.present? && doi.blank? && model.include?('Dataset')
  end

  def doi_required_metadata_present?
    self[Rdr::Index::Fields.title].present? && self[Rdr::Index::Fields.creator].present? && available.present?
  end

  def format
    self[Rdr::Index::Fields.format]
  end

  def in_works_ids
    self[Rdr::Index::Fields.in_works_ids]
  end

  def is_replaced_by
    self[Rdr::Index::Fields.is_replaced_by]
  end

  def model
    self['has_model_ssim']
  end

  def provenance
    self[Rdr::Index::Fields.provenance]
  end

  def related_url
    self[Rdr::Index::Fields.related_url]
  end

  def replaces
    self[Rdr::Index::Fields.replaces]
  end

  def resource_type
    self[Rdr::Index::Fields.resource_type]
  end

  def rights_note
    self[Rdr::Index::Fields.rights_note]
  end

  def temporal
    self[Rdr::Index::Fields.temporal]
  end

  def members
    self['member_ids_ssim'] || []
  end

  def top_level
    self['top_level_bsi'] || false
  end

  def previous_dataset_version_query
    ActiveFedora::SolrService
      .query(previous_dataset_version_query_params)
      .map { |hit| SolrDocument.new(hit) }
  end

  def previous_dataset_version_query_params
    ActiveFedora::SolrQueryBuilder.construct_query([[ Rdr::Index::Fields.doi, replaces ]])
  end

  def next_dataset_version_query
    ActiveFedora::SolrService
      .query(next_dataset_version_query_params)
      .map { |hit| SolrDocument.new(hit) }
  end

  def next_dataset_version_query_params
    ActiveFedora::SolrQueryBuilder.construct_query([[ Rdr::Index::Fields.doi, is_replaced_by ]])
  end


end
