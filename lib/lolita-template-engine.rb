require 'lolita'

module Lolita
  module TemplateEngine

  end
end

require 'lolita-template-engine/module'
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

