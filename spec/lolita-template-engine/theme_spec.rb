require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Lolita::TemplateEngine::Theme do
  let(:theme_path){File.join(TEST_THEMES_PATH,"theme_one")}
  let(:bad_path){File.join(TEST_THEMES_PATH,"bad_theme")}
  let(:bad_path2){File.join(TEST_THEMES_PATH,"bad_theme2")}
  let(:theme){Lolita::TemplateEngine::Theme.new(theme_path)}

  it "should create new theme" do
    Lolita::TemplateEngine::Theme.new(theme_path)
  end

  it "should raise error when there is no path given" do
    expect{
      Lolita::TemplateEngine::Theme.new(nil)
    }.to raise_error(ArgumentError,"Path not found")
  end

  it "should raise error when path is not a directory" do
    expect{
      Lolita::TemplateEngine::Theme.new(File.join(TEST_THEMES_PATH,"some_file.txt"))
    }.to raise_error(ArgumentError,"Path not found")
  end

  it "should raise error when theme doesn't have layouts directory" do
    expect{
      Lolita::TemplateEngine::Theme.new(bad_path)
    }.to raise_error(Lolita::TemplateEngine::Error, "Layouts directory not found in theme (bad_theme)")
  end

  it "should raise error when theme doesn't have content blocks directory" do
    expect{
      Lolita::TemplateEngine::Theme.new(bad_path2)
    }.to raise_error(Lolita::TemplateEngine::Error, "Content blocks directory not found in theme (bad_theme2)")
  end

  it "should have layouts" do
    theme.layouts.should be_a Lolita::TemplateEngine::Theme::Layouts
  end

  it "should have content blocks" do
    theme.content_blocks.should be_a Lolita::TemplateEngine::Theme::ContentBlocks
  end

end