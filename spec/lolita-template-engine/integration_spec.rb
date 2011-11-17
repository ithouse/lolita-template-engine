require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Lolita template engine integration with themes" do
  let(:themes_path){::TEST_THEMES_PATH}
  let(:themes){Lolita::TemplateEngine::Themes.new(themes_path,true)}

  it "should recognize all themes" do
    Lolita::TemplateEngine::Themes.new(themes_path,true).should have(1).item
  end

  it "should raise errors when silent mode is off and theme is not valid" do
    expect{
      Lolita::TemplateEngine::Themes.new(themes_path).themes
    }.to raise_error(Lolita::TemplateEngine::Error)
  end

  it "should have content blocks in theme" do
    themes[:theme_one].content_blocks.should have(2).items
  end

  it "should have layouts in theme" do
    themes[:theme_one].layouts.should have(2).items
  end

  it "should have placeholders in theme layouts" do
    themes[:theme_one].layouts[:home].placeholders.should have(2).items
    themes[:theme_one].layouts[:default].placeholders.should have(0).items
  end
end