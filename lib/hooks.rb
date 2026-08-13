=begin
module RedmineLocalAi
=end
class Hooks < Redmine::Hook::ViewListener
  # Este método deve ter exatamente o mesmo nome do hook do Redmine
  def view_issues_show_description_bottom(context = {})
    issue = context[:issue]
    controller = context[:controller]

    # Renderiza um arquivo parcial de visão (HTML/ERB) passando a tarefa atual
    controller.send(:render_to_string, {
      partial: 'issues/local_ai_box',
      locals: { issue: issue }
    })
  end
end

=begin
end
=end
