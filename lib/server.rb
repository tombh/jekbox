require_relative 'jekbox.rb'
require_relative 'file_handler.rb'

# Proxy
class Server
  def call(env)
    @request = Rack::Request.new(env)
    build_response unless pre_response_required?
    @response
  end

  def pre_response_required?
    [
      return_404_if_domain_not_managed,
      redirect_if_opposite_domain_is_canonical
    ].any?
  end

  def possible_file_paths
    @root = domain_to_folder
    path = File.expand_path(File.join(@root, '_site', @request.path_info))
    [
      # If this is just a normal request for a file, eg; example.com/assets/foo.css
      path,
      # If this is a request for pretty permalink, eg; example.com/blog-post
      File.join("#{path}.html"),
      # If this is a request for the index of a folder, eg; example.com/all-posts/
      File.join(path, 'index.html')
    ]
  end

  def file_path
    possible_file_paths.find do |path|
      File.file? path
    end
  end

  def domain_to_folder
    Jekbox.all_config[@request.host]['location']
  end

  def return_404_if_domain_not_managed
    build_404 unless Jekbox.all_config[@request.host]
  end

  def redirect_if_opposite_domain_is_canonical
    return unless opposite_domain_is_canonical?
    @response = [
      301,
      { 'Location' => "http://#{opposite_domain}" },
      []
    ]
  end

  def opposite_domain
    if @request.host.start_with? 'www'
      @request.host.gsub(/^www\./, '')
    else
      "www.#{@request.host}"
    end
  end

  def opposite_domain_is_canonical?
    Jekbox.all_config.key? opposite_domain
  end

  def build_response
    @file = file_path
    if @file
      build_file_response
    else
      build_404
    end
    build_head if @request.head?
  end

  def build_file_response
    raise unless @file.include? @root # Prevent malicious path requests
    file_info = FileHandler.file_info @file
    body = file_info[:body]
    time = file_info[:time]
    @headers = { 'Last-Modified' => time }

    if time == @request.env['HTTP_IF_MODIFIED_SINCE']
      @response = [304, @headers, []]
    else
      return_200 body
    end
  end

  def return_200(body)
    @headers.update(
      'Content-Length' => body.bytesize.to_s,
      'Content-Type'   => FileHandler.media_type(@file)
    )
    @response = [200, @headers, [body]]
  end

  def build_404
    body = not_found_message
    headers = {
      'Content-Length' => body.bytesize.to_s,
      'Content-Type'   => 'text/html'
    }
    @response = [404, headers, [body]]
  end

  def return_head
    status, headers, _body = @response
    [status, headers, []]
  end

  def not_found_message
    custom_404 || default_404
  end

  def default_404
    'Not found'
  end

  def custom_404
    return unless @root
    filename = File.join @root, '/404.html'
    return nil unless File.exist? filename
    filename ? FileHandler.file_info(filename)[:body] : nil
  end
end
