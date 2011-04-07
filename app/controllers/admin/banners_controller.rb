class Admin::BannersController < Admin::ResourceController
  model_class Banner
  # TODO: Find out why the banner_placements are only updated when one is added.
  paginate_models
  login_required
  only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove, :destroy, :deactivate, :remove_all_placements!,
    :when => [:designer, :admin],
    :denied_url => { :controller => 'admin/pages', :action => 'index' },
    :denied_message => 'You must have designer privileges to perform this action.'

  before_filter :check_cookie, :only => [:index]
  skip_after_filter :clear_model_cache, :only => [:destroy]

  def check_cookie
    unless params[:sort]
      params[:sort] = cookies['banner_sort'] ? cookies['banner_sort'] : 'name'
    end
    %w(active inactive).each do |view|
      if cookies['banner_view'] == view && params[:view] != view
        flash.keep
        redirect_to :view => view and return
      end
    end
  end

  def deactivate
    @banner = Banner.find(params[:id])
    case true
      when request.post? && @banner.unprotected?
        @banner.remove_all_placements!
        redirect_to admin_banners_url
      when @banner.protected?
        flash[:error] = @banner.cannot_be_deactivated_msg
        redirect_to admin_banners_url
      else
        response_for :deactivate
    end
  end

  def remove
    @banner = Banner.find(params[:id])
    if @banner.unprotected?
      response_for :remove
    else
      flash[:error] = @banner.cannot_be_removed_msg
      redirect_to admin_banners_url
    end
  end

  def destroy
    @banner = Banner.find(params[:id])
    if @banner.unprotected?
      super
      clear_model_cache
    else
      flash[:error] = @banner.cannot_be_removed_msg
      redirect_to admin_banners_url
    end
  end

end
