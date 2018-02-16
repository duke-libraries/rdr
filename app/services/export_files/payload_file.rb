require 'digest'

module ExportFiles
  class PayloadFile

    attr_reader :fileset, :nested_path

    delegate :original_file, to: :fileset

    def initialize(fileset, nested_path)
      @fileset = fileset
      @nested_path = nested_path
    end

    def to_s
      "work #{fileset.parent.id}, fileset #{fileset.id}, file #{file_name}"
    end

    def content
      original_file.content
    end

    def file_digest
      original_file.checksum
    end

    def file_name
      original_file.original_name
    end

  end
end
