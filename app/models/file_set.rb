# Generated by hyrax:models:install
class FileSet < ActiveFedora::Base
  PRIMARY = 'primary'.freeze
  PRESERVATION = 'supplementary'.freeze
  SUPPLEMENTAL = 'supplementary'.freeze

  property :pcdm_use, predicate: 'http://pcdm.org/use', multiple: false do |index|
    index.as :facetable
  end

  property :file_type, predicate: 'http://purl.org/dc/elements/1.1/format', multiple: false do |index|
    index.as :facetable
  end

  def primary?
    pcdm_use == PRIMARY
  end

  def supplementary?
    !primary?
  end

  include ::Hyrax::FileSetBehavior

  directly_contains_one :preservation_master_file, through: :files, type: ::RDF::URI('http://pcdm.org/use#PreservationMasterFile'), class_name: 'Hydra::PCDM::File'
  directly_contains_one :service_file, through: :files, type: ::RDF::URI('http://pcdm.org/use#ServiceFile'), class_name: 'Hydra::PCDM::File'
  directly_contains_one :intermediate_file, through: :files, type: ::RDF::URI('http://pcdm.org/use#IntermediateFile'), class_name: 'Hydra::PCDM::File'
  directly_contains_one :transcript_file, through: :files, type: ::RDF::URI('http://pcdm.org/use#Transcript'), class_name: 'Hydra::PCDM::File'
  directly_contains_one :extracted, through: :files, type: ::RDF::URI('http://pcdm.org/use#ExtractedText'), class_name: 'Hydra::PCDM::File'
end
