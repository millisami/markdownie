require 'rubygems'
require 'sinatra'
require 'pathname'
require 'rdiscount'
require 'json'
require 'haml'

module Markdownie
  class << self
    def watch dir
      raise ArgumentError, "dir needs to be a directory" unless File.directory? dir
      @watching = Pathname.new(dir)
    end

    def render file
      RDiscount.new(File.read(@watching + file)).to_html.chomp
    end

    def files
      @files = Dir["#{dir}/*.md"].map { |file| Pathname.new(file).relative_path_from(@watching).to_s }
    end

    def dir
      @watching.cleanpath.to_s
    end

    def install_path
      Pathname.new(__FILE__).dirname.realpath.to_s
    end

    def css_path stylesheet
      source = File.exists?(dir + "/css/#{stylesheet}") ? dir : install_path
      source + "/css/#{stylesheet}"
    end
  end
end

configure do
  set :port => 5678
end

get '/' do
  @files = Markdownie.files
  @dir = Markdownie.dir
  haml :home
end

get '/css/:css' do
  content_type 'text/css'
  File.read Markdownie.css_path(params[:css])
end

get '/file/:path' do
  file  = Markdownie.dir + "/#{params[:path]}"
  @markup = Markdownie.render params[:path]
  body haml(:file) unless params[:raw]
end
