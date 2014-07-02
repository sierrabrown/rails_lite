require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require 'debugger'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise "already built" if already_built_response?
    @res.body = content
    @res["Content-Type"] = type
    @res.status = 200
    @already_built_response = true
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    raise "already built" if already_built_response?
    @res.header["location"] =  url
    @res.status = 302
    @already_built_response = true
    @session.store_session
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    content = ERB.new(File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")).result(binding)
    render_content(content, 'text/html')
    @session.store_session
  end

  # method exposing a `Session` object
  def session
    @session ||= JSON.parse(self)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    unless @already_built_response
      render name.to_sym
    end
  end
end
