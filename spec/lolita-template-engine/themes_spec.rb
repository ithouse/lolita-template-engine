require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Lolita::TemplateEngine::Themes do 
  let(:themes_path){::TEST_THEMES_PATH}
  let(:themes){Lolita::TemplateEngine::Themes.new(themes_path,true)}

  it "should create new" do
    Lolita::TemplateEngine::Themes.new(themes_path,true)
  end

  it "should raise error when no path is given and no Rails defined" do
    expect{
      Lolita::TemplateEngine::Themes.new
    }.to raise_error(ArgumentError, "No app root given")
  end

  it "should collect all themes on initialize" do
    themes.names.should include("theme_one")
  end

  it "should lazy load themes" do
    themes.instance_variable_get(:"@themes").should be_empty
    themes.themes.should_not be_empty
  end

  it "should find theme by name" do
    themes.theme("theme_one").should be_a(Lolita::TemplateEngine::Theme)
  end

  it "should access theme through square bracket" do
    themes["theme_one"].should be_a(Lolita::TemplateEngine::Theme)
  end

  it "should access theme through themes singelton method" do
    themes.themes.theme_one.should be_a(Lolita::TemplateEngine::Theme)
  end

  it "should access theme throug method" do
    themes.theme_one.should be_a(Lolita::TemplateEngine::Theme)
  end
end