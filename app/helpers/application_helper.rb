module ApplicationHelper
  def attribution
    '<div>Some icons made by <a href="http://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a>             is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>'.html_safe
  end

  #def submit_or_return_to(return_path, text = 'Save')
    #haml_tag :table, {:style => 'padding-top:30px'} do
      #haml_tag :tr do
        #haml_tag :td, {:width => '180px'} do
          #haml_tag :input, {:type => 'submit', :value => text, :style => "margin-right: 100px"}
        #end
        #haml_tag :td do
          #haml_tag :a, "Cancel", {:href => return_path}
        #end
      #end
    #end
  #end

  #def focus(input)
    #haml_tag :script, "$(function(){$('##{input}').focus()})"
  #end

  #def nav_enable(path)
    #current_role_permits?(path) ? 'enabled' : 'disabled'
  #end

  def current_user_permitted?(path)
    user_is_developer? || permissions_granted?(path)
  end

  def user_is_developer?
    current_user.is_developer? if current_user
  end

  def permissions_granted?(path)
    controller = Controller.find_by_controller_name(path[:controller])
    action = Action.find_by_action_name_and_controller_id(path[:action],controller.id) unless controller.nil?
    user_roles = current_user ? current_user.user_roles : []
    role_ids = user_roles.map(&:role_id)
    role_ids.any?{|rid| action && ActionRole.exists?(:action_id => action.id, :role_id => rid )}
  end

  #def current_role_permits?(path)
    #controller = Controller.find_by_controller_name(path[:controller])
    #action = Action.find_by_action_name_and_controller_id(path[:action],controller.id) unless controller.nil?
    #role_ids = session[:role].current_role_ids
    #role_ids.any?{|rid| action && ActionRole.exists?(:action_id => action.id, :role_id => rid )}
  #end
  #def nav_dropdown(text, menu)
    ## when links are all populated, hide this navbar menu toggle when all links are not permitted for current user
    ## for maintainability, the navbar should be extracted into a navbar ruby object
    ## which handles permissions, translations, links and navigation hierarchy
    #haml_tag 'li.dropdown' do
      #haml_tag 'a.dropdown-toggle', {:href => "#", :"data-toggle"=>"dropdown", :role=>"button", :"aria-expanded"=>"false"} do
        #haml_concat t(text)
        #haml_tag 'span.caret'
      #end
      #haml_tag 'ul.dropdown-menu', {:role => :menu} do
        #menu.each do |menu_text, href|
          #haml_tag :li do
            #haml_tag :a, t(menu_text), {:href => href}
          #end
        #end
      #end
    #end
  #end
end

#module ActionView
  #module Helpers
    #class FormBuilder
      #def yes_no_radio_buttons(method, options = {})
        #buttons = "Yes"
        #buttons += @template.radio_button(
          #@object_name, method, true, objectify_options(options)
        #)
        #buttons += "No"
        #buttons += @template.radio_button(
          #@object_name, method, false, objectify_options(options)
        #)
        #buttons.html_safe
      #end


      ## select_or_freetext(:select_method, select_choices, :freetext_method, *select_options)
      ## produces a select combo box with method = :select_method, and options= select_choices and options=select_options (optional argument)
      ## the options must contain an option with a value "Enter as free form text..."
      ## the select box includes javascript onchange event responder that will hide/display
      ## a text field with associated method freetext_method.
      ## when the "Enter as free form text..." option is selected, the text field is displayed
      #def select_or_freetext(select_method, select_choices, freetext_method, select_options={})
        #out = @template.select(@object_name, select_method, select_choices, select_options, {:onchange=>"change_to_freetext(this)", :class=>'select_with_freetext_option'})

        #out += @template.text_field(@object_name, freetext_method, :object=>@object, :id=>freetext_method, :size=>50, :style=>'display:none', :class=>'freetext')

        #script = <<-EOS
          #document.onload = initialize_freetext_fields();

          #function initialize_freetext_fields(){
            #$('.select_with_freetext_option').each(function(i,el){ initialize(el)})
          #};

          #function initialize(select){
            #var l = $(select).siblings('input');

              #var values = _($('option', select)).pluck('value')
              #console.log("values" + values)
              #var vals = _.compact(values)
              #var val = l.val()
              #console.log("val" + val)
              #if(val != "" && vals.indexOf(val) == -1){ // it's not a select option value
                #l.show();
                #var index = vals.indexOf("add referrer...");
                #select.selectedIndex = index;
                #console.log("index "+index)
              #}else{
                #l.hide()
              #}
            #}

          #function change_to_freetext(select){
            #var l = $(select).siblings('input');
            #if ( select.selectedIndex != -1 && select.options[select.selectedIndex].text.match(/add referrer.../i) )
               #{ l.show(); l.focus() }
            #else{l.val("");l.hide()}
            #}
        #EOS
        #out += @template.content_tag(:script, script.html_safe)
        #out.html_safe
      #end
    #end
  #end

#end # /ActionView


