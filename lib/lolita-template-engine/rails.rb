module LolitaTemplateEngine
  class Engine < Rails::Engine
    config.before_initialize do
      Lolita.themes.each do |name,theme|
        debugger
        config.paths["app/views"].push(theme.paths.views)
        config.paths["app/assets"] << theme.paths.assets
      end
    end
  end
end

