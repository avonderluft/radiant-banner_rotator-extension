class BannerRotatorExtension < Radiant::Extension
  
  version "#{File.read(File.expand_path(File.dirname(__FILE__)) + '/VERSION')}"
  description "Allows addition and independent management of rotating banners on pages."
  url "https://github.com/avonderluft/radiant-banner_rotator-extension"

  def activate
    Page.send :include, BannerRotator::PageExtensions
    Page.send :include, BannerRotator::Tags
    tab "Content" do
      add_item "Banners", '/admin/banners', :after => "Pages"
    end
    admin.page.index.add :node, 'banners_column', :before => 'status_column'
    admin.page.index.add :sitemap_head, 'banners_column_header', :before => 'status_column_header'
    admin.pages.edit.add :form, 'banner_info', :after => 'edit_extended_metadata'
    
    Radiant::AdminUI.class_eval do
      attr_accessor :banner
      alias_method "banners", :banner
    end
    admin.banner = load_default_banner_regions
  end

  def load_default_banner_regions
    returning OpenStruct.new do |banner|
      banner.edit = Radiant::AdminUI::RegionSet.new do |edit|
        edit.main.concat %w{edit_header edit_form}
        edit.form.concat %w{edit_title edit_content}
        edit.form_bottom.concat %w{edit_buttons edit_timestamp}
      end
      banner.index = Radiant::AdminUI::RegionSet.new do |index|
        index.top.concat %w{}
        index.thead.concat %w{title_header pages_header actions_header}
        index.tbody.concat %w{title_cell pages_cell actions_cell}
        index.bottom.concat %w{new_button}
      end
      banner.new = banner.edit
    end
  end

end