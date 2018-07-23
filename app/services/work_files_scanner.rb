class WorkFilesScanner

  attr_reader :ability, :results, :work_id

  delegate :file_count, :file_size_total, to: :results

  ScanResults = Struct.new(:file_count, :file_size_total)

  def self.call(work_id, ability=nil)
    self.new(work_id, ability).scan
  end

  def initialize(work_id, ability)
    @work_id = work_id
    @ability = ability
  end

  def scan
    init_scan_results
    work_doc = SolrDocument.find(work_id)
    scan_work(work_doc)
    results
  end

  private

  def init_scan_results
    @results = ScanResults.new.tap do |r|
      r.file_count = 0
      r.file_size_total = 0
    end
  end

  def scan_work(work_doc)
    work_doc.members.each do |member|
      member_doc = SolrDocument.find(member)
      if permitted?(member_doc)
        if member_doc.hydra_model == FileSet
          scan_fileset(member_doc)
        else
          scan_work(member_doc)
        end
      end
    end
  end

  def scan_fileset(fileset_doc)
    results.file_count = results.file_count + 1
    file_size = fileset_doc['file_size_lts'] || 0
    results.file_size_total = results.file_size_total + file_size
  end

  def permitted?(obj)
    ability.present? ? ability.can?(:read, obj) : true
  end

end
