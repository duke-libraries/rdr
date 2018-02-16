require 'bagit'
require 'uri'

module ExportFiles
  class Package
    include ActiveModel::Validations

    BASENAME_MAX_LENGTH = 64

    attr_accessor :scan_results
    attr_reader :ability, :archive, :basename, :builder, :repo_id

    delegate :add_file, :data_dir, :manifest!, to: :bag
    delegate :path, to: :storage

    validates_presence_of :basename, :repo_id

    def self.call(*args)
      new(*args).tap do |pkg|
        pkg.export!
      end
    end

    def initialize(repo_id, ability: nil, basename: nil)
      @ability = ability
      @basename = basename.to_s.strip
      @repo_id = repo_id
    end

    def scanner
      @scanner ||= Scanner.new(work, ability: ability)
    end

    def scan
      @scan_results ||= scanner.scan
    end

    def expected_payload_size
      scan_results.file_size_total
    end

    def expected_num_files
      scan_results.file_count
    end

    def export!
      Packager.new(self, work, ability: ability).build!
      manifest!
      archive!
    end

    def bag_info
      { 'Source-Organization' => Rdr.export_files_source_organization,
        'Contact-Email' => Rdr.export_files_contact_email,
        'External-Identifier' => work.doi.first }.compact
    end

    def work
      @work ||= ActiveFedora::Base.find(repo_id)
    end

    def storage
      @storage ||= Storage.call(basename)
    end

    def bag
      @bag ||= BagIt::Bag.new(path, bag_info)
    end

    def archive!
      @archive = Archive.call(self)
    end

    def archived?
      !!archive
    end

    def url
      if archived?
        base_url + archive.path.sub("#{Storage.store}/", "")
      end
    end

    def base_url
      u = Rdr.export_files_base_url
      if Rdr.host_name
        u = [ "https://", Rdr.host_name, u ].join
      end
      u
    end

    def add_payload_file(payload_file)
      PayloadFilePackager.call(self, payload_file)
    end

    def self.normalize_work_title(title, max_length)
      title.gsub(/[^\w\.\-]/, '_')[0..max_length-1]
    end
  end
end
