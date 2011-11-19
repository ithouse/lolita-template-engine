require 'lolita'
require 'ruby-debug'
module Lolita
  module TemplateEngine
    
  end
end

module LolitaTemplateEngineConfiguration
  def themes
    @themes ||= Lolita::TemplateEngine::Themes.new
  end
end

Lolita.scope.extend(LolitaTemplateEngineConfiguration)

require 'lolita-template-engine/errors'
require 'lolita-template-engine/module'

# All about themes
require 'lolita-template-engine/themes'
require 'lolita-template-engine/theme'
require 'lolita-template-engine/theme/layouts'
require 'lolita-template-engine/theme/placeholders'
require 'lolita-template-engine/theme/content_blocks'
require 'lolita-template-engine/theme/file_processor'

if Lolita.rails3?
  require 'lolita-template-engine/rails'
end

Lolita.after_routes_loaded do
  if tree=Lolita::Navigation::Tree[:"left_side_navigation"]
    unless tree.branches.detect{|b| b.options[:system_name] == "layouts"}
      branch=tree.append(nil,:title => ::I18n.t("lolita-template-engine.layouts"), :system_name => "layouts" )
      
      branch.append(Object,:title=>::I18n.t("lolita-template-engine.layouts"),:url=>Proc.new{|view,branch|
        view.send(:lolita_layouts_path)
      }, :active=>Proc.new{|view,parent_branch,branch|
        request = view.send(:request)
        request.path.to_s.match(/lolita\/layouts/)
      })
      branch.append(Object,:title=>::I18n.t("lolita-template-engine.content blocks"),:url=>Proc.new{|view,branch|
        view.send(:lolita_content_blocks_path)
      }, :active=>Proc.new{|view,parent_branch,branch|
        request = view.send(:request)
        request.path.to_s.match(/lolita\/content_blocks/)
      })
    end
  end
end

