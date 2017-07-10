module ApplicationHelper
  def submit_or_return_to(return_path)
    haml_tag :table, {:class => :table, :style => 'margin-top:30px; width:280px'} do
      haml_tag :tr do
        haml_tag :td, {:width => '180px'} do
          haml_tag :input, {:type => 'submit', :value => t('defaults.save')}
        end
        haml_tag :td do
          haml_tag :a, t('defaults.cancel'), {:href => return_path}
        end
      end
    end
  end

  def focus(input)
    haml_tag :script, "$(function(){$('##{input}').focus()})".html_safe
  end

end
