require File.dirname(__FILE__) + '/../spec_helper'

describe "BannerRotator::PageExtensions" do
  dataset :pages, :banners
  
  it "should have some banner and banner placements" do
    pages(:home).should respond_to(:banners)
    pages(:home).should respond_to(:banner_placements)
    pages(:home).should have(2).banners
  end
  
  it "should select a banner" do
    [ banners(:first), banners(:protected) ].should include(pages(:home).select_banner)
  end
  
  it "should inherit banners from its ancestors" do
    pages(:article).banner_placements.should == pages(:home).banner_placements
    [ banners(:first), banners(:protected) ].should include(pages(:article).select_banner)
  end
  
  it "should not delete its parent's banner placements when destroyed" do
    pages(:home).should == pages(:radius).parent
    lambda { pages(:radius).destroy }.should_not change(BannerPlacement, :count)
  end
end