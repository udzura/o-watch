module ShibuyaHelper
  ALL_HOUSE_ID_LIST = LiveHouse.all.map(&:id).sort

  def h2(str)
    h(str.gsub(/<.*>/, ""))
  end

  def to_info(str)
    h2(str).gsub("\n", "<br />")
  end

  def emphasize_q(str, query)
    str.gsub(/#{query}/, "<span style='background-color:#fee;color:#a00;font-weight:bold;'> #{h(query)} </span>")
  end

  def head_navi_link(the_date, date_range)
    t = []
    t << ((the_date == date_range.first) ? "#top" : "#dt#{(the_date - 1).day}")
    t << ((the_date == date_range.last) ? "#bottom" : "#dt#{(the_date + 1).day}")
    " #{link_to '△', t[0]}#{link_to '▽', t[1]}"
  end

  def sub_navi_link(the_date, house_idx, house_count, opts={})
    t = ""
    d = the_date.day
    if house_idx <= 0
      t << (opts[:for] == :one_day ? link_to("↑", "#top", :id => "#{d}_#{house_idx}_u") :
          "<a id='#{d}_#{house_idx}_u'>　</a>")
    else
      t << (link_to '↑',
        "##{d}_#{house_idx - 1}_u",
        :id => "#{d}_#{house_idx}_u")
    end
    if house_idx >= house_count - 1
      t << (opts[:for] == :one_day ? link_to("↓", "#bottom", :id => "#{d}_#{house_idx}_d") :
          "<a id='#{d}_#{house_idx}_d'>　</a>")
    else
      t << (link_to '↓',
        "##{d}_#{house_idx + 1}_d",
        :id => "#{d}_#{house_idx}_d")
    end
    t
  end

  def search_navi_link(the_id, ids)
    t = []
    t << ((the_id == ids.first) ? "#top" : "#res#{ids[ids.index(the_id) - 1]}")
    t << ((the_id == ids.last) ? "#bottom" : "#res#{ids[ids.index(the_id) + 1]}")
    " #{link_to '△', t[0]}#{link_to '▽', t[1]}"
  end

  def schedule_paginate(page, count, q)
    t = []
    max = (count + 4) / 5
    return "" if max <= 1
    prev_link = ((page <= 1) ? "前" :
        link_to("前(*)", {:query => q, :p => page - 1}))
    next_link = ((page >= max) ? "次" :
        link_to("次(#)", {:query => q, :p => page + 1}))
    (1..max).each do |p|
      html_param = {}
      t << ((p == page) ? p.to_s :
          link_to(p.to_s, {:query => q, :p => p}, html_param))
    end
    "#{prev_link} #{t.join(" ")} #{next_link}"
  end
end
