require 'importer'

class BatchImport
  include ActiveModel::Model

  attr_reader :checksum_file, :files_directory, :manifest_file, :model, :on_behalf_of

  CONFIG_FILE = File.join(Rails.root, 'config', 'batch_import.yml')

  validates_presence_of :manifest_file, :files_directory
  validate :manifest_file_must_exist, if: Proc.new { manifest_file.present? }
  validate :files_directory_must_exist, if: Proc.new { files_directory.present? }
  validate :manifest_contents_must_be_valid, if: Proc.new { manifest_file_exists? && files_directory.present? }
  validate :checksum_file_must_exist, if: Proc.new { checksum_file.present? }
  validate :on_behalf_of_user_must_exist, if: Proc.new { on_behalf_of.present? }

  def self.default_config
    { basepath: File.join(Rails.root, 'tmp', 'imports') }
  end

  def self.config
    if File.exists?(CONFIG_FILE)
      YAML.load(File.read(CONFIG_FILE)).deep_symbolize_keys
    else
      default_config
    end
  end

  def self.basepath
    config[:basepath]
  end

  def initialize(args)
    @checksum_file = args['checksum_file']
    @files_directory = args['files_directory']
    @manifest_file = args['manifest_file']
    @model = args['model'] || 'Dataset'
    @on_behalf_of = args['on_behalf_of']
  end

  def manifest_file_exists?
    manifest_file.present? ? File.exist?(manifest_file_full_path) : false
  end

  def checksum_file_full_path
    File.join(self.class.basepath, checksum_file) if checksum_file.present?
  end

  def files_directory_full_path
    File.join(self.class.basepath, files_directory)
  end

  def manifest_file_full_path
    File.join(self.class.basepath, manifest_file)
  end

  def checksum_file_must_exist
    unless File.exist?(checksum_file_full_path)
      errors.add(:checksum_file, I18n.t('rdr.does_not_exist', target: checksum_file_full_path))
    end
  end

  def files_directory_must_exist
    unless Dir.exist?(files_directory_full_path)
      errors.add(:files_directory, I18n.t('rdr.does_not_exist', target: files_directory_full_path))
    end
  end

  def manifest_file_must_exist
    unless manifest_file_exists?
      errors.add(:manifest_file, I18n.t('rdr.does_not_exist', target: manifest_file_full_path))
    end
  end

  def manifest_contents_must_be_valid
    manifest = Importer::CSVManifest.new(manifest_file_full_path, files_directory_full_path)
    unless manifest.valid?
      manifest.errors.full_messages.each do |msg|
        errors.add(:manifest_file, msg)
      end
    end
  end

  def on_behalf_of_user_must_exist
    unless User.find_by_user_key(on_behalf_of).present?
      errors.add(:on_behalf_of, "#{on_behalf_of} does not exist")
    end
  end

end
