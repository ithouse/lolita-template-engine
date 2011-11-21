Rails.application.routes.draw do

  namespace "lolita" do
    resources :layouts, :only => [:new,:create,:edit,:update,:show]
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

  lolita_for :layouts, :class_name => "LolitaLayout", :only => [:index,:destroy], :visible => false
  lolita_for :content_blocks, :class_name => "LolitaContentBlock", :visible => false
end