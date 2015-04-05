module ActionView::Helpers::UrlHelper
  # here we overwrite the link_to  and button_to methods,
  # to produce a zero length string if the current user is not permitted
  # for this action, otherwise a proper link is generated
  def link_to_with_permission_check(name, options = {}, html_options = {}, &block)
    url = case options
          when String
            options
          when :back
            request.env["HTTP_REFERER"] || 'javascript:history.back()'
          else
            self.url_for(options)
          end

    # assume to be permitted
    if javascript?(url)
      return link_to_without_permission_check name, options, html_options, &block
    end

    #unless options == :back
    method = html_options.blank? || html_options[:method].nil? ? :get : html_options[:method]
    opt = url.split("?")
    opt = opt[0]
    opt = opt.gsub(/http\:\/\/(.*?)\//,"/")
    route = Rails.application.routes.recognize_path(opt, :method=>method.to_sym)
    controller = route[:controller]
    action = route[:action]
    #end

    if current_user_permitted?({:controller => controller, :action => action})
      link_to_without_permission_check name, options, html_options, &block
    else
      ""
    end
  end

  alias_method_chain  :link_to, :permission_check


  def button_to(name, options = {}, html_options = {})
    # it's a modified version of the standard button_to, that returns nothing if the current user is not permitted for this action
    html_options = html_options.stringify_keys
    convert_boolean_attributes!(html_options, %w( disabled ))

    method_tag = ''
    if (method = html_options.delete('method')) && %w{put delete}.include?(method.to_s)
      method_tag = tag('input', :type => 'hidden', :name => '_method', :value => method.to_s)
    end

    form_method = method.to_s == 'get' ? 'get' : 'post'

    request_token_tag = ''
    if form_method == 'post' && protect_against_forgery?
      request_token_tag = tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
    end

    if confirm = html_options.delete("confirm")
      html_options["onclick"] = "return #{confirm_javascript_function(confirm)};"
    end

    url = options.is_a?(String) ? options : self.url_for(options)
    name ||= url

    opt = url.split("?")
    query_string = opt[1]
    opt = opt[0]
    opt = opt.gsub(/http\:\/\/(.*?)\//,"/")
    #puts "url is: #{escape_once url}"
    #puts "form method is: #{form_method}"
    #puts "opt is: #{opt}"
    if url.match(/_method=(.*?)&amp/) then recognize_method = url.match(/_method=(.*?)&amp/)[1] else recognize_method = form_method end # it's a special case workaround for rails bug that caused me to use the _method technique for forcing a get method to be interpreted
    route = Rails.application.routes.recognize_path(opt, :method=>recognize_method.to_sym)
    controller = route[:controller]
    action = route[:action]
    #puts "route is: #{route.inspect}"
    #puts "controller is: #{controller}"
    #puts "action is: #{action}"
    if !current_user_permitted?(controller,action) then return "" end

    # this is a hack to get a button that uses the get method and sends a query string
    # it appears that browsers strip any query string that is appended to the "action" url
    # when the get method is stipulated in the form tag
    # the browser will permit a query string if the post method is stipulated, but
    # this is not REST compliant
    # prior to Rails 2.3, a _method=get parameter could be included in the query string
    # with the actual button method being post, but this seems to have been removed in Rails
    unless query_string.nil? || query_string.empty?
      query, query_tags=[], ""
      query_string.split('&amp;').each { |q| query << q.split('=') }
      query.each { |q| query_tags += tag("input", {:name=>q[0],:value=>q[1],:type=>:hidden}) }
    else
      query_tags = ''
    end

    html_options.merge!("type" => "submit", "value" => name)

    ("<form method=\"#{form_method}\" action=\"#{escape_once url}\" class=\"button-to\"><div>" +
     method_tag + tag("input", html_options) + request_token_tag + query_tags + "</div></form>").html_safe
  end

private
  def javascript?(url)
    url == '#' || url == 'javascript:void(0)' || url == 'javascript: void(0)'
  end

end
