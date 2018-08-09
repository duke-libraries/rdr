module Rdr::Scripts::Migration
  class MigrateComponentArks

    attr_reader :ark_map_file, :dryrun, :logger

    def initialize(ark_map_file:, dryrun: true, logger: nil)
      @ark_map_file = ark_map_file
      @dryrun = dryrun
      @logger = logger || Logger.new(STDOUT)
    end

    def execute
      banner
      update_filesets
    end

    def banner
      logger.info(self.class.name)
      logger.info("Dryrun: #{dryrun?}")
    end

    def ark_map
      @ark_map ||= as_csv_table(ark_map_file)
    end

    def as_csv_table(file)
      CSV.read(file, headers: true)
    end

    def update_filesets
      ark_map.each do |row|
        logger.info('=' * 72)
        logger.info("Processing #{row['id']} with #{row['ark']}")
        file_sets = filesets_to_update(row)
        case
        when file_sets.count == 0
          logger.warn("Skipped - No (remaining) checksum matches without an ARK")
        when file_sets.count > 1
          logger.error("Skipped - Multiple checksum matches #{row['checksum']}")
        else
          update_fileset(file_sets.first, row['ark'], row['id'])
        end
        logger.info('=' * 72)
      end
    end

    def update_fileset(fileset, ark, id)
      fileset.ark = ark
      fileset.save! unless dryrun?
      logger.info("Added ARK #{fileset.ark} to #{fileset.id} (#{id})")
    end

    def filesets_to_update(row)
      checksum_matches = FileSet.where('digest_ssim' => "urn:sha1:#{row['checksum']}")
      logger.info("#{checksum_matches.count} match(es) for checksum #{row['checksum']}")
      checksum_matches.select { |fs| needs_ark?(fs) }
    end

    def needs_ark?(fileset)
      logger.info("Excluding #{fileset.id} -- Already has ARK #{fileset.ark}") unless fileset.ark.blank?
      fileset.ark.blank?
    end

    def dryrun?
      dryrun
    end

  end
end
