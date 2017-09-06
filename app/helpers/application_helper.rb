module ApplicationHelper
  def attribution
    '<div>Some icons made by <a href="http://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a>             is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>'.html_safe
  end

  def menu_text(strategic_plan)
    strategic_plan.current? ?
      strategic_plan.title + " (current)" :
      strategic_plan.title
  end

  def current_user_permitted?(path)
    is_logout?(path) || user_is_developer? || permissions_granted?(path)
  end

  # even user with no privileges can logout!
  def is_logout?(path)
    path[:controller] == 'authengine/sessions' && path[:action] == 'destroy'
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

end


