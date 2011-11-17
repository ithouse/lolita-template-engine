require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Lolita::TemplateEngine::Theme::Placeholders do
  let(:theme){Lolita::TemplateEngine::Theme.new(File.join(TEST_THEMES_PATH,"theme_one"))}
  let(:layouts){Lolita::TemplateEngine::Theme::Layouts.new(theme)}
  let(:layout_path){File.join(layouts.path,"home.html.erb") }
  let(:layout){Lolita::TemplateEngine::Theme::Layout.new(layout_path)}
  let(:placeholders){Lolita::TemplateEngine::Theme::Placeholders.new(layout)}

  it "should create new placeholder" do
    Lolita::TemplateEngine::Theme::Placeholders.new(layout)
  end

  it "should have many placeholders" do
    placeholders.placeholder("top_banner").should be_a(Lolita::TemplateEngine::Theme::Placeholder)
    placeholders[:main_block].should be_a(Lolita::TemplateEngine::Theme::Placeholder)
  end

  it "should return all names of its placeholders" do
    placeholders.names.sort.should == ["main_block","top_banner"]
  end

  describe "Placeholder" do
    let(:default_options){{:name => "home", :width => 11, :height => 12, :disabled => "false"}}
    
    it "should create new" do
      ph = Lolita::TemplateEngine::Theme::Placeholder.new(default_options)
      ph.width.should == 11
      ph.height.should == 12
      ph.disabled.should be_false
      ph.name.should == "home"
      ph.stretch.should be_nil
    end
  end
end