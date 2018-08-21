module Rdr::Scripts::Migration
  class UpdateArkTargets

    attr_reader :logger, :dryrun, :limit

    def initialize(logger: nil, dryrun: false, limit: 9999999)
      @logger = logger || Logger.new(STDOUT)
      @dryrun = dryrun
      @limit = limit
    end

    def execute
      logger.info("DRYRUN is set to #{dryrun}")
      logger.info("LIMIT is set to #{limit}")

      datasetctr = process(Dataset)
      filesetctr = process(FileSet)

      logger.info("#{datasetctr} Datasets are updated")
      logger.info("#{filesetctr} Filesets are updated")
    end

    def process(model)
      ctr = 0
      model.find_each do |obj|
        logger.info("starting #{model.name}  #{obj.id}")
        if obj.ark.present?
          ark = Ark.new(obj)
          ark.target! unless dryrun?
          ctr += 1
          logger.info("#{obj.id} #{model.name} ark target updated to: #{ark.local_url}")
        else
          logger.warn(".. this #{model.name} does not have an ark")
        end
        break if ctr >= limit
      end
      ctr
    end

    def dryrun?
      dryrun
    end

  end
end
