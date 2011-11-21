ActiveSupport.on_load(:action_view) {
  include Lolita::TemplateEngine::ViewHelpers
}

ActiveSupport.on_load(:action_controller) {
  include Lolita::TemplateEngine::ControllerHelpers
}

module LolitaTemplateEngine
  class Engine < Rails::Engine
    config.before_initialize do |app|
      Lolita.themes.each do |name,theme|
        # app.config.paths["app/views"].push("app/themes/business/views")
        ActionController::Base.view_paths = ActionController::Base.view_paths + [theme.paths.views]
        app.config.paths["app/assets"] << theme.paths.assets
        app.config.autoload_paths += %W(#{app.config.root}/app/presenters)
      end
    end
  end
end

