require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Lolita::TemplateEngine::Theme::ContentBlocks do
  let(:theme){Lolita::TemplateEngine::Theme.new(File.join(TEST_THEMES_PATH,"theme_one"))}
  let(:content_blocks){Lolita::TemplateEngine::Theme::ContentBlocks.new(theme)}

  it "should create new " do
    cb = Lolita::TemplateEngine::Theme::ContentBlocks.new(theme)
    cb.theme.should  == theme
  end

  it "should have path" do
    File.exist?(content_blocks.path).should be_true
  end

  it "should have content blocks" do
    content_blocks.content_block("list").should be_a(Lolita::TemplateEngine::Theme::ContentBlock)
    content_blocks[:"list"].should be_a(Lolita::TemplateEngine::Theme::ContentBlock)
  end

  it "should return names" do
    content_blocks.names.sort.should == ["banner","list"]
  end


  describe "ContentBlock" do
    let(:path){File.join(theme.paths.content_blocks,"_list.html.haml")}
    
    it "should create new" do
      cb= Lolita::TemplateEngine::Theme::ContentBlock.new(path)
      cb.name.should ==  "list"
      cb.path.should == path
    end

    it "should read attributes from file" do
      list = content_blocks[:list]
      list.width.should == 100
      list.height.should == 200
      list.single.should be_false
    end

    it "should raise error when dimensions is not specified " do
      expect{
        Lolita::TemplateEngine::Theme::ContentBlock.new(File.join(theme.paths.content_blocks,"support_files","other_file.html.erb"))
      }.to raise_error(ArgumentError, /Dimensions must be specified through/)
    end
  end
end