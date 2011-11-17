require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Lolita::TemplateEngine::Theme::Layouts do
  let(:theme){Lolita::TemplateEngine::Theme.new(File.join(TEST_THEMES_PATH,"theme_one"))}
  let(:layouts){Lolita::TemplateEngine::Theme::Layouts.new(theme)}

  it "should create new layouts" do
    Lolita::TemplateEngine::Theme::Layouts.new(theme)
  end

  it "should have path to layouts" do
    layouts.path.should match(/layout/)
  end

  it "should collect all theme layouts" do
    layouts.names.sort.should == ["default","home"]
  end

  it "should have layouts" do
    layouts[:default].should be_a(Lolita::TemplateEngine::Theme::Layout)
    layouts.layout("default").should be_a(Lolita::TemplateEngine::Theme::Layout)
  end

  describe "Layout" do
    let(:layout_path){File.join(layouts.path,"default.html.haml") }
    let(:layout){Lolita::TemplateEngine::Theme::Layout.new(layout_path,"default")}

    it "should create new" do
      Lolita::TemplateEngine::Theme::Layout.new(layout_path)
    end

    it "should have human_name" do
      layout.human_name.should == "Default"
    end
  end

end