module ExportFiles
  class Packager

    attr_reader :ability, :package, :work_id

    delegate :add_payload_file, :add_tag_file, :metadata_report, to: :package

    WORK_PATH_MAX_LENGTH = 30

    def initialize(package, work_id, ability:)
      @package = package
      @work_id = work_id
      @ability = ability
    end

    def build!
      work_doc = SolrDocument.find(work_id)
      handle_work(work_doc, PayloadFilePackager::PAYLOAD_PATH)
      add_tag_file("metadata-report.txt") do |f|
        f.write(metadata_report)
      end
    end

    def handle_work(work_doc, nested_path=nil)
      nested_work_count = 0
      ordered_work_ids(work_doc.id).each do |wrk_id|
        wrk_doc = SolrDocument.find(wrk_id)
        if permitted?(wrk_doc)
          nested_work_count = nested_work_count + 1
          nstd_path = File.join(nested_path, work_path(wrk_doc, nested_work_count)) if nested_path
          handle_work(wrk_doc, nstd_path)
        end
      end
      file_set_ids(work_doc.id).each do |fileset_id|
        fileset = FileSet.find(fileset_id)
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

    # Logic adapted from Hyrax::MemberPresenterFactory#ordered_ids
    def ordered_member_ids(work_id)
      query = "proxy_in_ssi:#{work_id}"
      results = ActiveFedora::SolrService.query(query, rows: 10_000, fl: 'ordered_targets_ssim')
      results.flat_map { |x| x.fetch("ordered_targets_ssim", []) }
    end

    # Logic adapted from Hyrax::MemberPresenterFactory#file_set_ids
    def file_set_ids(work_id)
      query = "{!field f=has_model_ssim}FileSet"
      filter = "{!join from=ordered_targets_ssim to=id}id:\"#{work_id}/list_source\""
      results = ActiveFedora::SolrService.query(query, rows: 10_000, fl: ActiveFedora.id_field, fq: filter)
      results.flat_map { |x| x.fetch(ActiveFedora.id_field, []) }
    end

    # Logic suggested by Hyrax::MemberPresenterFactory#work_presenters
    def ordered_work_ids(work_id)
      ordered_member_ids(work_id) - file_set_ids(work_id)
    end

  end
end
