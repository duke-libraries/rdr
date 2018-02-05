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

  def format
    self[Rdr::Index::Fields.format]
  end

  def provenance
    self[Rdr::Index::Fields.provenance]
  end

  def related_url
    self[Rdr::Index::Fields.related_url]
  end

  def resource_type
    self[Rdr::Index::Fields.resource_type]
  end

  def temporal
    self[Rdr::Index::Fields.temporal]
  end


end
