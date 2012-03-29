require 'pathname'

module Gopher
  module Handlers
    #
    # handle browsing a directory structure/returning files to the client
    #
    class DirectoryHandler < BaseHandler

      attr_accessor :path, :filter

      #
      # opts:
      # filter -- a subset of files to show to user
      # path -- the base path of the filesystem to work from
      #
      def initialize(opts = {})
        opts = {
          :filter => "*.*",
          :path => Dir.getwd
        }.merge(opts)

        @path = opts[:path]
        @filter = opts[:filter]
      end

      def sanitize(p)
#        File.absolute_path(Pathname.new(p).cleanpath.to_s)
        Pathname.new(p).cleanpath.to_s
      end

      def contained?(p)
        (p =~ /^#{@path}/) != nil
      end

      #
      # take the incoming parameters, and turn them into a path
      #
      def request_path(params)
        File.absolute_path(sanitize(params[:splat]), @path)
        #File.join(@path, sanitize(params[:splat]))
      end


      #
      # handle a request
      #
      def call(params = {}, request = nil)
        puts "call #{params.inspect}, #{request.inspect}"

        lookup = request_path(params)

        puts "*** #{lookup}"

        raise Gopher::InvalidRequest if ! contained?(lookup)

        if File.directory?(lookup)
          directory(lookup)
        elsif File.file?(lookup)
          file(lookup)
        else
          raise Gopher::NotFoundError
        end
      end

      #
      # generate a directory listing
      #
      def directory(dir)
        m = Menu.new(@application)
        Dir.glob("#{dir}/#{filter}").each do |x|
          m.link File.basename(x), x
        end
        m.to_s
      end

      #
      # return a file handle -- this will be sent as the request response
      #
      def file(f)
        File.new(f)
      end

    end
  end
end
