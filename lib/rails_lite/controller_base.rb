require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require_relative 'router'


class ControllerBase
  attr_reader :params, :req, :res, :already_build_response

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req 
    @res = res
    @already_build_response = false
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    if !already_rendered?
      @res.body = content
      @res.content_type = type
      @already_build_response = true
    else
      raise "already_rendered"
    end
  end

  # helper method to alias @already_rendered
  def already_rendered? 
    return @already_build_response
  end

  # set the response status code and header
  def redirect_to(url)    
    if !already_rendered?
      @res.status = 302
      @res['location'] = url

      @already_build_response = true
    else
      raise "already_rendered"
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    if !already_rendered?
      page = ERB.new(File.read("views/users_controller/#{template_name}.html.erb"))
      @res.body = page.result(binding)
      @res.content_type = "text/html"
      @already_build_response = true
    else
      raise "already_rendered"
    end
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@request)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    p name
    unless name.nil?
      self.send(name)
      render(name) unless already_rendered?
    end
  end
end

