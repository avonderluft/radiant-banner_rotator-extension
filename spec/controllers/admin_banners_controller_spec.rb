#require File.dirname(__FILE__) + '/../spec_helper'
require 'spec_helper'
require_dependency 'admin/banners_controller'
class Admin::BannersController < Admin::ResourceController; def rescue_action(e); raise e; end end

describe Admin::BannersController do
  # Uses Admin::ResourceController, built into Radiant
  dataset :users, :banners

  before :each do
    @banner = banners(:first)
    @count = Banner.count
    login_as(:admin)
  end

  it "should require login" do
    logout
    lambda { get :index }.should                require_login
    lambda { get :show, :id => 1 }.should       require_login
    lambda { get :new }.should                  require_login
    lambda { post :create}.should               require_login
    lambda { get :edit, :id => 1 }.should       require_login
    lambda { put :update, :id => 1 }.should     require_login
    lambda { get :remove, :id => 1 }.should     require_login
    lambda { delete :destroy, :id => 1 }.should require_login
    lambda { post :deactivate, :id => 1 }.should require_login
  end
  
  it "'create' should add 1 banner and redirect to index" do
    post :create, :banner => min_valid_banner_params
    Banner.count.should == @count + 1
    response.should be_redirect
    response.should redirect_to(admin_banners_path)
  end

  it "'update' should redirect to index" do
    put :update, :id => @banner.id
    Banner.count.should == @count
    response.should be_redirect
    response.should redirect_to(admin_banners_path)
  end
  
  it "'deactivate' should remove all banner placements and redirect to index" do
    @banner.active?.should be_true
    post :deactivate, :id => @banner.id
    @banner.inactive?.should be_true
    Banner.count.should == @count
    response.should be_redirect
    response.should redirect_to(admin_banners_path)
    # flash notices are largely deprecated in as of 0.9
    # flash[:notice].should include("Banner \"#{@banner.name}\" has been deactivated.") 
  end
  
  it "'delete' should remove 1 banner and redirect to index" do
    delete :destroy, :id => @banner.id
    Banner.count.should == @count - 1
    response.should be_redirect
    response.should redirect_to(admin_banners_path)
    # flash notices are largely deprecated in as of 0.9
    # flash[:notice].should include("Banner has been deleted.")
  end
  
  describe "protected banners" do

    def protected_banner_behavior_on_deactivate
      response.should be_redirect
      response.should redirect_to(admin_banners_path)
      flash[:error].should == @banner.cannot_be_deactivated_msg
      @banner.active?.should be_true
      @banner.protected?.should be_true
    end
    
    def protected_banner_behavior_on_remove
      response.should be_redirect
      response.should redirect_to(admin_banners_path)
      flash[:error].should == @banner.cannot_be_removed_msg
      Banner.count.should == @count
    end
    
    def protected_from_removal_tests
      get :remove, :id => @banner.id
      protected_banner_behavior_on_remove
      delete :destroy, :id => @banner.id
      protected_banner_behavior_on_remove
    end
    
    def protected_from_deactivation_tests
      get :deactivate, :id => @banner.id
      protected_banner_behavior_on_deactivate
      post :deactivate, :id => @banner.id
      protected_banner_behavior_on_deactivate
    end

    it "should protect banners with 'protected' in the banner name from removal" do
      @banner = banners(:protected)
      protected_from_removal_tests
    end
    
    it "should protect banners with 'protected' in the banner name from deactivation" do
      @banner = banners(:protected)
      protected_from_deactivation_tests
    end

    it "should protect banners named in Radiant::Config['admin.protected_banners'] from removal" do
      @banner = banners(:child_2_1)
      Radiant::Config['admin.protected_banners'] = @banner.name
      protected_from_removal_tests
    end
    
    it "should protect banners named in Radiant::Config['admin.protected_banners'] from deactivation" do
      @banner = banners(:child_2_1)
      Radiant::Config['admin.protected_banners'] = @banner.name
      protected_from_deactivation_tests
    end
  
  end

  [:admin, :designer].each do |user|
    describe "#{user} user" do
      before :each do
        @banner = Banner.find(:first)
        login_as user
      end

      def redirects_to_index
        response.should be_redirect
        response.should redirect_to(admin_banners_url)
      end

      it 'should have access to the index action' do
        get :index
        response.should be_success
      end
      
      it 'should have access to the show action' do
        get :show, :id => @banner.id
        response.should be_redirect
        response.should redirect_to(edit_admin_banner_url(@banner))
      end
      
      it 'should have access to the new action' do
        get :new
        response.should be_success
      end
      
      it 'should have access to the create action' do
        post :create, :banner => min_valid_banner_params
        redirects_to_index
      end
      
      it 'should have access to the edit action' do
        get :edit, :id => 1
        response.should be_success
      end
      
      it 'should have access to the update action' do
        put :update, :id => 1
        redirects_to_index
      end
      
      it "should have access to the remove action" do
        get :remove, :id => 1
        response.should be_success
      end
      
      it 'should have access to the destroy action' do
        delete :destroy, :id => 1
        redirects_to_index
      end
      
      it 'should have access to the deactivate action' do
        post :deactivate, :id => 1
        redirects_to_index
      end
    end
  end
  
  [:existing, :non_admin].each do |user|
    describe "#{user} user" do
      before :each do
        login_as user
      end
  
      def redirects_to_pages
        response.should be_redirect
        response.should redirect_to(admin_pages_path)
        flash[:error].should == 'You must have designer privileges to perform this action.'
      end
  
      it 'should not have access to the index action' do
        get :index
      end
      
      it 'should not have access to the show action' do
        get :show, :id => 1
      end
      
      it 'should not have access to the new action' do
        get :new
      end
      
      it 'should not have access to the create action' do
        post :create
      end
      
      it 'should not have access to the edit action' do
        get :edit, :id => 1
      end
      
      it 'should not have access to the update action' do
        put :update, :id => 1
      end
  
      it 'should not have access to the remove action' do
        put :remove, :id => 1
      end
      
      it 'should not have access to the destroy action' do
        delete :destroy, :id => 1
      end
      
      it 'should not have access to the deactivate action' do
        post :deactivate, :id => 1
      end
      
      after :each do
        redirects_to_pages
      end
    end
  end

end
