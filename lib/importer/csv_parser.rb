module Importer
  # rubocop:disable Metrics/ClassLength
  class CSVParser
    include Enumerable

    def initialize(file_name)
      @file_name = file_name
    end

    # @yieldparam attributes [Hash] the attributes from one row of the file
    def each(&_block)
      headers = nil
      CSV.foreach(@file_name) do |row|
        if headers
          # we already have headers, so this is not the first row.
          yield attributes(headers, row)
        else
          # Grab headers from first row
          headers = validate_headers(row)
        end
      end
    end

    private

    def validate_headers(row)
      row.compact!
      difference = (row - valid_headers)
      raise "Invalid headers: #{difference.join(', ')}" unless difference.blank?
      row
    end

    def valid_headers
      Dataset.attribute_names + %w(collection_id parent_ark visibility file)
    end

    def attributes(headers, row)
      {}.tap do |processed|
        headers.each_with_index do |header, index|
          extract_field(header, row[index], processed)
        end
      end
    end

    def extract_field(header, val, processed)
      return unless val
      extract_multi_value_field(header, val, processed)
    end

    def extract_multi_value_field(header, val, processed, key = nil)
      key ||= header.to_sym
      processed[key] ||= []
      val = val.strip
      # Workaround for https://jira.duraspace.org/browse/FCREPO-2038
      val.delete!("\r")
      processed[key] << val
    end

  end
  # rubocop:enable Metrics/ClassLength
end
