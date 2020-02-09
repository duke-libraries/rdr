module ExportFiles
  class MetadataReport

    attr_reader :pkg

    def self.call(pkg)
      new(pkg).generate
    end

    def initialize(pkg)
      @pkg = pkg
    end

    def generate
      r = [ I18n.t('rdr.batch_export.metadata_report.first_line', title: work_doc.title.first) ]
      r << export_package_info
      r << I18n.t('rdr.batch_export.metadata_report.dataset_metadata_title')
      report_entries.each do |entry|
        if work_doc.send(entry).present?
          label = I18n.t("rdr.show.fields.#{entry}")
          value = Array(work_doc.send(entry)).join('; ')
          r << "#{label}: #{value}"
        end
      end
      r << "#{I18n.t('rdr.show.fields.available')}: #{publication_date}" if publication_date.present?
      r << "#{I18n.t('rdr.batch_export.metadata_report.source_organization')}: #{Rdr.export_files_source_organization}"
      r << "#{I18n.t('rdr.batch_export.metadata_report.contact_email')}: #{Rdr.export_files_contact_email}"
      size, count = file_size_and_count
      human_size = ActiveSupport::NumberHelper.number_to_human_size(size)
      r << "#{I18n.t('rdr.batch_export.metadata_report.file_count')}: #{count.to_i}"
      r << "#{I18n.t('rdr.batch_export.metadata_report.file_size')}: #{human_size}"
      r << "#{I18n.t('rdr.batch_export.metadata_report.export_timestamp')}: #{Time.now}"
      r << I18n.t('rdr.batch_export.metadata_report.deposit_agreement_title')
      r << acceptable_use_policy
      r.join("\n\n")
    end

    def publication_date
      if work_doc.available.present?
        Array(work_doc.available.map { |entry| DateTime.parse(entry).strftime('%Y-%m-%d') }).join('; ')
      end
    end

    def file_size_and_count
      pkg.bag.payload_oxum.split('.')
    end

    def report_entries
      [ 'creator', 'affiliation', 'alternative', 'ark', 'temporal', 'contact', 'contributor', 'bibliographic_citation',
        'description', 'doi', 'format', 'funding_agency', 'grant_number', 'is_replaced_by', 'language',
        'based_near_label', 'provenance', 'publisher', 'related_url', 'replaces', 'license', 'rights_note', 'subject',
        'title', 'resource_type' ]
    end

    def export_package_info
      File.read(File.join(File.dirname(__FILE__), 'export_package_info.txt'))
    end

    def acceptable_use_policy
      File.read(File.join(File.dirname(__FILE__), 'acceptable_use_policy.txt'))
    end

    def work_doc
      @work_doc ||= SolrDocument.find(pkg.repo_id)
    end

  end
end
