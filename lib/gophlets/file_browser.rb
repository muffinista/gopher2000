module Gopher
  class FileBrowser < Gopher::Gophlet
    attr_accessor :root

    def initialize(base, root)
      raise Errno::ENOENT unless File.directory?(root)
      @root = File.expand_path(root)
      super(base)
    end

    def dispatch(selector)
      path = File.join(root, selector)
      if File.directory? path
        render :directory, base, path # check for index?
      elsif File.file? path
        return File.open(path)
      else
        raise NotFound, 'File or directory not found'
      end
    end

    templates do
      menu :directory do |base, dir|
        Dir["#{dir}/*"].each do |path|
          basename = File.basename(path)
          if File.directory? path
            menu basename, File.join(base, basename)
          else
            link basename, File.join(base, basename)
          end
        end
        text "---"
      end
    end
  end
end
