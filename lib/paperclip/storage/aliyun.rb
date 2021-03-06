module Paperclip
  module Storage
    module Aliyun

      def exists?(style = default_style)
        oss_connection.exists? path(style)
      end

      def flush_writes #:nodoc:
        @queued_for_write.each do |style_name, file|
          oss_connection.put path(style_name), File.new( file.path ), additional_opts(file)
        end

        after_flush_writes

        @queued_for_write = {}
      end

      def flush_deletes #:nodoc:
        @queued_for_delete.each do |path|
          oss_connection.delete path
        end

        @queued_for_delete = []
      end

      def copy_to_local_file(style = default_style, local_dest_path)
        remote_path = path( style )

        log("copying #{remote_path} to local file #{local_dest_path}")

        oss_connection.get( remote_path ) do |body|
          ::File.open(local_dest_path, 'wb') do |file|
            file.write body
          end
        end
      end

      def oss_connection
        @oss_connection ||= ::Aliyun::Connection.new
      end

      # NOTICE:
      # do NOT set these headers:
      #
      # - Authorization
      # - Content-Type
      # - Content-Length
      # - Date
      # - Host
      # - Expect
      #
      # They will be set automaticly
      def additional_opts file
        headers = @options[:aliyun_oss_headers] || {}
        headers.each do |k, v|
          headers[k] = v.respond_to?( :call ) ? v.call(file) : v
        end
        {
          content_type: file.content_type,
          headers:      headers
        }
      end
    end
  end
end
