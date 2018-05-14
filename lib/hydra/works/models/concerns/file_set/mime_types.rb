# This was taken directly from Sufia's GenericFile::MimeTypes
module Hydra::Works
  module MimeTypes
    extend ActiveSupport::Concern

    def pdf?
      self.class.pdf_mime_types.include? mime_type
    end

    def image?
      self.class.image_mime_types.include? mime_type
    end

    def video?
      self.class.video_mime_types.include? mime_type
    end

    def audio?
      self.class.audio_mime_types.include? mime_type
    end

    def office_document?
      self.class.office_document_mime_types.include? mime_type
    end

    def vector_file?
      self.class.vector_mime_types.include? mime_type
    end

    def data_file?
      self.class.data_mime_types.include? mime_type
    end

    def text_file?
      self.class.text_mime_types.include? mime_type
    end

    def script_file?
      self.class.script_mime_types.include? mime_type
    end


    module ClassMethods
      def image_mime_types
        ['image/png', 'image/jpeg', 'image/jpg', 'image/jp2', 'image/bmp', 'image/gif', 'image/tiff']
      end

      def pdf_mime_types
        ['application/pdf']
      end

      def video_mime_types
        ['video/mpeg', 'video/mp4', 'video/webm', 'video/x-msvideo', 'video/avi', 'video/quicktime', 'application/mxf']
      end

      def audio_mime_types
        # audio/x-wave is the mime type that fits 0.6.0 returns for a wav file.
        # audio/mpeg is the mime type that fits 0.6.0 returns for an mp3 file.
        ['audio/mp3', 'audio/mpeg', 'audio/wav', 'audio/x-wave', 'audio/x-wav', 'audio/ogg']
      end

      def office_document_mime_types
        # removed rtf
        ['application/msword',
         'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
         'application/vnd.oasis.opendocument.text',
         'application/vnd.ms-excel',
         'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
         'application/vnd.ms-powerpoint',
         'application/vnd.openxmlformats-officedocument.presentationml.presentation']
      end

      def vector_mime_types
        ['application/postscript', 'text/x-gle', 'image/svg+xml']
        # eps, gle, svg -- .plot is application/octet-stream
      end

      def data_mime_types
        ['application/octet-stream', 'text/csv', 'application/sla', 'application/zip']
        # CEL, CELa, COL, csv, dat, dta, opj, pcb, STL, zip
      end

      def text_mime_types
        ['text/markdown', 'text/x-markdown', 'application/rtf', 'application/x-rtf', 'text/richtext', 'text/plain']
        # md, rtf, txt
      end

      def script_mime_types
        ['application/matlab', 'application/mfile', 'application/x-matlab-data', 'application/x-python-code', 'text/x-python']
        # m, mat, py, -- m, gp, R?? -- xmg is application/octet-stream
      end

    end
  end
end
