class Schedule < ActiveRecord::Base
  belongs_to :live_house

  def live_house_name
    if live_house
      live_house.name
    else
      nil
    end
  end

  def indexer
    "#{title}|_*_*_*|#{desc}"
  end

  def date_atr
    date.strftime("%Y%m%d").to_i
  end

  acts_as_searchable :searchable_fields => [:indexer],
                     :attributes => {:ym => nil, :date_atr => nil, :live_house_id => nil}

  attr_accessor :html_snippet
  
  def html_snippet
    snip_title, snip_desc = *(@html_snippet.split("|_*_*_*|"))
    "<h3>#{snip_title}</h3>
    #{snip_desc}"
  end

  def html_snippet_mobile
    snip_title, snip_desc = *(
      @html_snippet.gsub(/<b>/i, "<u>").gsub(/<\/b>/i, "</u>").split("|_*_*_*|")
    )
    return <<EOH
<div style="background-color:#eee4dd;color:#332200;">
<h4>&#xE6F6;#{snip_title}</h4>
</div>
<p>&#xE691;#{snip_desc.gsub(/<[^u]*?>/, "").gsub("\n", "<br />")}</p>
EOH
  end

  #monkey patch
  def self.fulltext_search2(q, opts={})
    self.find(:all, :conditions => ["(schedules.title like ? or schedules.desc like ?)", "%#{q}%", "%#{q}%"])
  end
end
