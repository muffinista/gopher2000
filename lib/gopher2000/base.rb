module Gopher

  #
  # main application class for a gopher server. holds all the
  # methods/data required to interact with clients.
  #
  class Application

    # The output pattern we will use to generate access logs
    ACCESS_LOG_PATTERN = "%d\t%m\n"

    @@access_log = nil
    @@debug_log = nil

    @routes = []
    @menus = {}
    @text_templates = {}
    @scripts ||= []

    attr_accessor :menus, :text_templates, :routes, :config, :scripts, :last_reload, :params, :request


    #
    # reset the app. clear out any routes, templates, config values,
    # etc. this is used during the load process
    #
    def reset!
      self.routes = []
      self.menus = {}
      self.text_templates = {}
      self.scripts ||= []
      self.config ||= {
        :debug => false,
        :host => "0.0.0.0",
        :port => 70
      }

      register_defaults

      self
    end

    #
    # return the host we will use when outputting gopher menus
    #
    def host
      config[:host] ||= '0.0.0.0'
    end

    #
    # return the port we will use when outputting gopher menus
    #
    def port
      config[:port] ||= 70
    end

    #
    # return the application environment
    #
    def env
      config[:env] ||= 'development'
    end

    #
    # are we in debugging mode?
    #
    def debug_mode?
      config[:debug] == true
    end


    #
    # check if our script has been updated since the last reload
    #
    def should_reload?
      ! last_reload.nil? && self.scripts.any? do |f|
        File.mtime(f) > last_reload
      end
    end

    #
    # reload scripts if needed
    #
    def reload_stale
      reload_check = should_reload?
      self.last_reload = Time.now

      return if ! reload_check
      reset!

      self.scripts.each do |f|
        debug_log "reload #{f}"
        load f
      end
    end


    #
    # mount a directory for browsing via gopher
    #
    # @param [Hash] path A hash specifying the path your route will answer to, and the filesystem path to use '/route' => '/home/path/etc'
    # @param [Hash] opts a hash of options for the mount. Primarily this is a filter, which will restrict the list files outputted. example: :filter => '*.jpg'
	# @param [Class] klass The class that should be used to handle this mount. You could write and use a custom handler if desired
    #
    # @example mount the directory '/home/user/foo' at the gopher path '/files', and only show JPG files:
    #   mount '/files' => '/home/user/foo', :filter => '*.jpg'
    #
    def mount(path, opts = {}, klass = Gopher::Handlers::DirectoryHandler)
      debug_log "MOUNT #{path} #{opts.inspect}"
      opts[:mount_point] = path

      handler = klass.new(opts)
      handler.application = self

      #
      # add a route for the mounted class
      #
      route(globify(path)) do
        # when we call, pass the params and request object for this
        # particular request
        handler.call(params, request)
      end
    end


    #
    # define a route.
    # @param [String] path the path your route will answer to. This is basically a URI path
    # @yield a block that handles your route
    #
    # @example respond with a simple string
    #   route '/path' do
    #     "hi, welcome to /path"
    #   end
    #
    # @example respond by rendering a template
    #   route '/render' do
    #     render :template
    #   end
    #
    def route(path, &block)
      selector = Gopher::Application.sanitize_selector(path)
      sig = compile!(selector, &block)

      debug_log("Add route for #{selector}")

      self.routes ||= []
      self.routes << sig
    end


    #
    # specify a default route to handle requests if no other route exists
    # @yield a block to handle the default route
    #
    # @example render a template
    #   default_route do
    #     render :template
    #   end
    #
    def default_route(&block)
      @default_route = Application.generate_method("DEFAULT_ROUTE", &block)
    end

    #
    # lookup an incoming path
    #
    # @param [String] selector the selector path of the incoming request
    #
    def lookup(selector)
      unless routes.nil?
		    routes.each do |pattern, keys, block|
          if match = pattern.match(selector)
            match = match.to_a
            url = match.shift
            
            params = to_params_hash(keys, match)

            #
            # @todo think about this
            #
            @params = params

            return params, block
          end
        end
      end

      unless @default_route.nil?
        return {}, @default_route
      end

      raise Gopher::NotFoundError
    end


    #
    # find and run the first route which matches the incoming request
    # @param [Request] req Gopher::Request object
    #
    def dispatch(req)
      debug_log(req)

      response = Response.new
      @request = req

      if ! @request.valid?
        response.body = handle_invalid_request
        response.code = :error
      elsif @request.url?
        response.body = handle_url(@request)
        response.code = :success
      else
        begin
          debug_log("do lookup for #{@request.selector}")
          @params, block = lookup(@request.selector)

          #
          # call the block that handles this lookup
          #
          response.body = block.bind(self).call
          response.code = :success
        rescue Gopher::NotFoundError => e
          debug_log("#{@request.selector} -- not found")
          response.body = handle_not_found
          response.code = :missing
        rescue Exception => e
          debug_log("#{@request.selector} -- error")
          debug_log(e.inspect)
          debug_log(e.backtrace)

          response.body = handle_error(e)
          response.code = :error
        end
      end

      access_log(req, response)
      response
    end

    #
    # define a template which will be used to render a gopher-style
    # menu.
    #
    # @param [String/Symbol] name the name of the template. This is what
    #   identifies the template when making a call to render
    # @yield a block which will output the menu. This block is
    #   executed within an instance of Gopher::Rendering::Menu and will
    #   have access to all of its methods.
    #
    # @example a simple menu:
    #  menu :index do
    #    # output a text entry in the menu
    #    text 'simple gopher example'
    #
    #    # use br(x) to add x space between lines
    #    br(2)
    #
    #    # link somewhere
    #    link 'current time', '/time'
    #    br
    #
    #    # another link
    #    link 'about', '/about'
    #    br
    #
    #    # ask for some input
    #    input 'Hey, what is your name?', '/hello'
    #    br
    #
    #    # mount some files
    #    menu 'filez', '/files'
    #  end
    #
    def menu(name, &block)
      menus[name.to_sym] = block
    end

    #
    # Define a template which will be used for outputting text. This
    # is not strictly required for outputting text, but it gives you
    # access to the methods defined in Gopher::Rendering::Text for
    # wrapping strings, adding simple headers, etc.
    #
    # @param [String/Symbol] name the name of the template. This is what identifies the template when making a call to render
    #
    # @yield a block which will output the menu. This block is executed within an instance of Gopher::Rendering::Text and will have access to all of its methods.
    # @example simple example
    #   text :hello do
    #     big_header "Hello There!"
    #     block "Really long text... ... the end"
    #     br
    #   end
    def text(name, &block)
      text_templates[name.to_sym] = block
    end

    #
    # specify a template to be used for missing requests
    #
    def not_found(&block)
      menu :not_found, &block
    end

    #
    # find a template
    # @param [String/Symbol] t name of the template
    # @return template block and the class context it should use
    #
    def find_template(t)
      x = menus[t]
      if x
        return x, Gopher::Rendering::Menu
      end
      x = text_templates[t]
      if x
        return x, Gopher::Rendering::Text
      end
    end

    #
    # Find the desired template and call it within the proper context
    # @param [String/Symbol] template name of the template to render
    # @param [Array] arguments optional arguments to be passed to template
    # @return result of rendering
    #
    def render(template, *arguments)
      #
      # find the right renderer we need
      #
      block, handler = find_template(template)

      raise TemplateNotFound if block.nil?

      ctx = handler.new(self)
      ctx.params = @params
      ctx.request = @request

      ctx.instance_exec(*arguments, &block)
    end

    #
    # get the id of the template that will be used when rendering a
    # not found error
    # @return name of not_found template
    #
    def not_found_template
      menus.include?(:not_found) ? :not_found : :'internal/not_found'
    end

    #
    # get the id of the template that will be used when rendering an error
    # @return name of error template
    #
    def error_template
      menus.include?(:error) ? :error : :'internal/error'
    end


    #
    # get the id of the template that will be used when rendering an html page
    # @return name of error template
    #
    def url_template
      menus.include?(:html) ? :html : :'internal/url'
    end
    
    #
    # get the id of the template that will be used when rendering an
    # invalid request
    # @return name of invalid_request template
    #
    def invalid_request_template
      menus.include?(:invalid_request) ? :invalid_request : :'internal/invalid_request'
    end


    #
    # Add helpers to the Base renedering class, which allows them to be called
    # when outputting the results of an action. Here's the code in Sinatra for reference:
    #
    # Makes the methods defined in the block and in the Modules given
    # in `extensions` available to the handlers and templates
    #  def helpers(*extensions, &block)
    #    class_eval(&block)   if block_given?
    #    include(*extensions) if extensions.any?
    #  end
    #
    # target - What class should receive the helpers -- defaults to Gopher::Rendering::Base, which will make it available when rendering
    # block -- a block which declares the helpers you want. for example:
    #
    # helpers do
    #  def foo; "FOO"; end
    # end
    def helpers(target = Gopher::Application, &block)
      target.class_eval(&block)
    end


    #
    # should we use non-blocking operations? for now, defaults to false if in debug mode,
    # true if we're not in debug mode (presumably, in some sort of production state. HAH!
    # Gopher servers in production)
    #
    def non_blocking?
      config.key?(:non_blocking) ? config[:non_blocking] : ! debug_mode?
    end


    #
    # add a glob to the end of this string, if there's not one already
    #
    def globify(p)
      p =~ /\*/ ? p : "#{p}/?*".gsub("//", "/")
    end

    #
    # compile a route
    #
    def compile!(path, &block)
      method_name = path
      route_method = Application.generate_method(method_name, &block)
      pattern, keys = compile path

      [ pattern, keys, route_method ]
    end

    #
    # turn a path string with optional keys (/foo/:bar/:boo) into a
    # regexp which will be used when searching for a route
    #
    # @param [String] path the path to compile
    #
    def compile(path)
      keys = []
      pattern = path.to_str.gsub(/[^\?\%\\\/\:\*\w]/) { |c| encoded(c) }
      pattern.gsub!(/((:\w+)|\*)/) do |match|
        if match == "*"
          keys << 'splat'
          "(.*?)"
        else
          keys << $2[1..-1]
          "([^/?#]+)"
        end
      end
      [/^#{pattern}$/, keys]
    end


    class << self

	    #
	    # Sanitizes a gopher selector
	    #
	    def sanitize_selector(raw)
		    "/#{raw}".dup.
		      strip. # Strip whitespace
		      sub(/\/$/, ''). # Strip last rslash
		      sub(/^\/*/, '/'). # Strip extra lslashes
		      gsub(/\.+/, '.') # Don't want consecutive dots!
	    end
      
	    #
      # generate a method which we will use to run routes. this is
      # based on #generate_method as used by sinatra.
      # @see https://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb
      # @param [String] method_name name to use for the method
      # @yield block to use for the method
      def generate_method(method_name, &block)
        define_method(method_name, &block)
        method = instance_method method_name
        remove_method method_name
        method
      end
    end
    
    #
    # output a debugging message
    #
    def debug_log(x)
      @@debug_logger ||= ::Logging.logger(STDERR)
      @@debug_logger.debug x
    end


    protected

    #
    # set up some default templates to handle errors, missing templates, etc.
    #
    def register_defaults
      menu :'internal/not_found' do
        error "Sorry, #{@request.selector} was not found"
      end

      menu :'internal/error' do |details|
        error "Sorry, there was an error #{details}"
      end

      menu :'internal/invalid_request' do
        error "invalid request"
      end

      menu :'internal/url' do
        output = <<-EOHTML
<html>
  <head>
    <meta http-equiv="refresh" content="5;URL=#{@request.url}">
  </head>
  <body>
    <p>
      You are following a link from gopher to a website. If your browser supports it, you will be
      automatically taken to the web site shortly.  If you do not get
      sent there, please click <a href="#{@request.url}">here</a>.
   </p>
   <p>
     The URL linked is: <a href="#{@request.url}">#{@request.url}</a>.
   </p>
   <p>Have a nice day!</p>
  </body>
</html>
EOHTML
        output
      end
    end

    def handle_not_found
      render not_found_template
    end

    def handle_url(request)
      render url_template, request
    end

    def handle_error(e)
      render error_template, e
    end

    def handle_invalid_request
      render invalid_request_template
    end



    #
    # where should we store access logs? if nil, don't store them at all
    # @return logfile path
    #
    def access_log_dest
      config.has_key?(:access_log) ? config[:access_log] : nil
    end

    #
    # initialize a Logger for tracking hits to the server
    #
    def init_access_log
      return if access_log_dest.nil?

      log = ::Logging.logger['access_log']
      pattern = ::Logging.layouts.pattern(:pattern => ACCESS_LOG_PATTERN)

      log.add_appenders(
        ::Logging.appenders.rolling_file(access_log_dest,
          :level => :debug,
          :age => 'daily',
          :layout => pattern)
        )

      log
    end

    #
    # write out an entry to our access log
    #
    def access_log(request, response)
      return if access_log_dest.nil?

      @@access_logger ||= init_access_log
      code = response.respond_to?(:code) ? response.code.to_s : "success"
      size = response.respond_to?(:size) ? response.size : response.length
      output = [request.ip_address, request.selector, request.input, code.to_s, size].join("\t")

      @@access_logger.debug output
    end


    #
    # zip up two arrays of keys and values from an incoming request
    #
    def to_params_hash(keys,values)
      hash = {}
      keys.size.times { |i| hash[ keys[i].to_sym ] = values[i] }
      hash
    end


  end
end
