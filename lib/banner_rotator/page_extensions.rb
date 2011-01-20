module BannerRotator
  module PageExtensions
    def self.included(base)
      base.class_eval do
        has_many :banner_placements
        has_many :banners, :through => :banner_placements
        alias_method_chain :banner_placements, :inheritance
        after_destroy :remove_assigned_banner_placements
      end
    end

    def banners_assigned?
      show_banner? && ! banners.empty?
    end

    def banners_inherited?
      show_banner? && banners.empty? && banner_placements.count > 0
    end

    def banner_placements_with_inheritance
      if banner_placements_without_inheritance.empty? && parent
        parent.banner_placements
      else
        banner_placements_without_inheritance
      end
    end

    def select_banner
      @banners_with_weighting ||= banner_placements.map do |p|
        [p.banner] * p.weight
      end.flatten
      
      x = rand(@banners_with_weighting.size)
      banner = @banners_with_weighting[x]
      @banners_with_weighting.delete(x+1)
      
      banner
    end

    private

    def remove_assigned_banner_placements
      BannerPlacement.delete_all("page_id = #{id}") if banners_assigned?
    end

  end
end