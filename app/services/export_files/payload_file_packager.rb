module ExportFiles
  class PayloadFilePackager

    PAYLOAD_PATH = "files"

    attr_reader :package, :payload_file

    delegate :file, :file_digest, :file_name, :nested_path, to: :payload_file
    delegate :stream, to: :file
    delegate :add_file, :data_dir, to: :package

    def self.call(*args)
      new(*args).call
    end

    def initialize(package, payload_file)
      @package = package
      @payload_file = payload_file
    end

    def call
      download
      verify_checksum
    end

    def download
      add_file(destination_path) do |io|
        io.binmode
        stream.each { |chunk| io.write(chunk) }
      end
    end

    def destination_path
      File.join(nested_path, file_name)
    end

    def verify_checksum
      FileUtils.cd(data_dir) do
        computed_digest = Digest.const_get(file_digest.algorithm).file(destination_path).hexdigest
        if file_digest.value != computed_digest
          raise Rdr::ChecksumInvalid, payload_file.to_s
        end
      end
    end

  end
end
