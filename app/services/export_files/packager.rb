module ExportFiles
  class Packager

    attr_reader :ability, :package, :work

    delegate :add_payload_file, to: :package

    WORK_PATH_MAX_LENGTH = 30

    def initialize(package, work, ability:)
      @package = package
      @work = work
      @ability = ability
    end

    def build!
      handle_work(work, PayloadFilePackager::PAYLOAD_PATH)
    end

    def handle_work(work, nested_path=nil)
      nested_work_count = 0
      work.ordered_works.each do |work|
        if permitted?(work)
          nested_work_count = nested_work_count + 1
          nstd_path = File.join(nested_path, work_path(work, nested_work_count)) if nested_path
          handle_work(work, nstd_path)
        end
      end
      work.file_sets.each do |fileset|
        if permitted?(fileset)
          handle_fileset(fileset, nested_path)
        end
      end
    end

    def handle_fileset(fileset, nested_path=nil)
      payload_file = PayloadFile.new(fileset, nested_path)
      add_payload_file(payload_file)
    end

    def work_path(work_doc, order)
      prefix = order_prefix(order) unless order.nil?
      "#{prefix}#{Package.normalize_work_title(work_doc.title.first, WORK_PATH_MAX_LENGTH)}"
    end

    def order_prefix(order)
      "#{order}_".rjust(5, '0')
    end

    def permitted?(obj)
      ability.can?(:read, obj)
    end

  end
end
