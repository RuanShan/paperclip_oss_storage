module Paperclip
  module Storage
    module Aliyun

      def exists?(style = default_style)
        oss_connection.exists? path(style)
      end

      def flush_writes #:nodoc:
        @queued_for_write.each do |style_name, file|
          oss_connection.put path(style_name), (File.new file.path)
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
    end
  end
end
