module BannerRotator::Tags
  include Radiant::Taggable

  desc %{
    Selects a banner from the rotating banners available to this page.
    If no banner is found for this page and banners are enabled, the page
    will inherit from its parent.  If no banners are found, or they are disabled for this page,
    then the tag will not be expanded.

    *Usage*:

    <pre><code><r:banner><!-- put some banner output code here --></r:banner></code></pre>
  }
  tag 'banner' do |tag|
    page = tag.locals.page
    tag.locals.banner = page.select_banner
    tag.expand if tag.locals.banner && page.show_banner?
  end

  %w{name background_image foreground_image link_url link_target image_style}.each do |att|
    desc %{
      Outputs the #{att} attribute of the current banner.

      *Usage*:

      <pre><code><r:banner><r:#{att} /></r:banner></code></pre>
    }
    tag "banner:#{att}" do |tag|
      tag.locals.banner.send(att)
    end
    desc %{
      Expands the contents if there is a non-empty #{att}.

      *Usage*:

      <pre><code>
      <r:banner>
        <r:if_#{att}>Content to display</r:if_#{att}>
      </r:banner>
      </code></pre>
    }
    tag "banner:if_#{att}" do |tag|
      tag.expand unless tag.locals.banner[att].blank?
    end
    tag "banner:content" do |tag|
      if tag.locals.banner['background_image'] =~ /swf/i
        "<a href=\"#{tag.locals.banner['link_url']}\" target=\"#{tag.locals.banner['link_target']}\"><object class=\"banner\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0\" width=\"160\" height=\"140\" bgcolor=\"#f0f7fd\"><param name=\"movie\" value=\"#{tag.locals.banner['background_image']}\"><param name=\"quality\" value=\"high\"><embed src=\"#{tag.locals.banner['background_image']}\" quality=\"high\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\" type=\"application/x-shockwave-flash\" width=\"160\" height=\"140\" bgcolor=\"#f0f7fd\"></embed></object></a>"
      else
        "<a href=\"#{tag.locals.banner['link_url']}\" target=\"#{tag.locals.banner['link_target']}\"><img src=\"#{tag.locals.banner['background_image']}\" /></a>"
      end
    end
    desc %{
      Expands the contents if there is no #{att}.

      *Usage*:

      <pre><code>
      <r:banner>
        <r:unless_#{att}>Content to display</r:unless_#{att}>
      </r:banner>
      </code></pre>
    }
    tag "banner:unless_#{att}" do |tag|
      tag.expand if tag.locals.banner[att].blank?
    end
  end
end
