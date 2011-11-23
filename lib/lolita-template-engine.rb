require 'lolita'
require 'ruby-debug'
module Lolita
  # Lolita::TemplateEngine add theming functionality to application. 
  # TemplateEngine consist of two parts. 
  # == First part
  # First part is theme recognization, that includes themes, layouts, placeholder and content blocks configuration.
  # It creates themes object, that consist of all information about all themes and their content.
  # 
  # == Second part
  # Second part is layout configuration and rendering into application. This part consist of Lolita resources,
  # that liks theme layout placeholders with content blocks and URLs. Each configuration may have may URLs,
  # when user request one of them than application switch layouts to recognized layout and render placeholders and
  # their content blocks inside it. Also this part helps to hand application specific data to theme-defined
  # content blocks. For detail of configuration see Lolita::TemplateEngine::Themes
  # 
  # === Data handling
  # Content block creators imagine what kind of data is neccessary for block to operate. When it is done, than for 
  # thoes who create application need to provide exactly same structured object to content block. This is done by creating
  # presenters in application.
  # First step is to collect your data in controller and give them to theme presenter.
  # ====Example
  #     class MyController
  #       def index
  #         @products = Product.all
  #         @last_reviews = Reviews.recently_created(5)
  #         @main_news = News.main
  #         current_theme.build_presenter(@products,@last_reviews,@news, true)
  #       end
  #    end
  # 
  # Second step is to create presenter class for theme. This is done by creating presenter class anywhere in project.
  # But recomended place would be app/presenters. Then create class that is named [ThemeName]Presenter.
  # ====Example
  #     # if we have *blue* theme
  #     class BluePresenter
  #       def initialize products,reviews,news, show_pictures = nil
  #         @products,@reviews,@news = products,reviews,news
  #         @show_pictures = show_pictures 
  #       end
  #       
  #       # this create array of other presenters at first call
  #       def products
  #         unless @products.first.is_a?(ProductPresenter)
  #           @products.map{|product| ProductPresenter.new(product)}
  #         end
  #         @products
  #       end
  #       
  #       # this just return received value
  #       def show_pictures
  #         @show_pictures
  #       end
  #       
  #       # This create variable of some other presenter
  #       def main_news
  #         @main_news ||= NewsPresenter.new(@news)
  #       end
  #       
  #       # this return hash for some content block that we don't want to use in our application
  #       def filter
  #         {:msg => "not supported"}
  #       end
  #     end
  # Remember that theme presenter should have methods for each content block it contains. Variables may not be presented 
  # but theme should return something (nil or whatsoever)
  # If you want to assign different presenter than you should define writer methods in presenter.
  # In presenter
  #     attr_writer :filter
  # In controller you assign whatever you want
  #     current_theme.build_presenter()
  #     presenter.filter = SpecialCaseFilter.new(request)
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
  require 'lolita-template-engine/rails/controller_helpers'
  require 'lolita-template-engine/rails/view_helpers'
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

