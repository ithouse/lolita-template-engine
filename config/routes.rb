Rails.application.routes.draw do

  namespace "lolita" do
    resources :themes, :only => :none do
      resources :layouts, :only => [:show] do
        collection do
          get :select
        end
        member do
          get :content_blocks
        end
      end
    end
  end

  lolita_for :layouts, :class_name => "LolitaLayout", :controller => "lolita/layouts", :append_to => "layouts"
  lolita_for :content_blocks, :class_name => "LolitaContentBlock", :append_to => "layouts" 
end