class LiquidRoomParser < ScheduleParser
  def parse_init
    @uri =
      "http://www.liquidroom.net/schedule/#{@@now.year}/#{'%02d' % @@now.mon}"
    return Nokogiri::HTML(open(@uri))
  end

  def get_descriptions
    (@doc/"//div[@class='contentsleft']/dl[2]/dt").each do |elm|
      tpl = {}
      tpl[:house_id] = 10
      day = elm.children.first.inner_text.match(/#{@@now.mon}\/(\d\d)/)[1].to_i
      tpl[:ym] = @@now.strftime("%Y%m")
      tpl[:date] = Date.new(@@now.year, @@now.mon, day)

      info_elm = elm.next_element
      tpl[:title] = "#{(info_elm/"h3").inner_text} #{(info_elm/"h4").inner_text}"

      tags = (info_elm/"p.tags").inner_text.strip
      dds = (info_elm/"dl/dd")
      desc_tmp = ""
      (info_elm/"dl/dt").each_with_index do |e, i|
        desc_tmp << "#{e.inner_text.strip} : #{dds[i].inner_text.strip}\n"
      end
      tpl[:desc] = "#{tags}\n#{desc_tmp.chomp}"

      tpl[:permlink] = (info_elm/"h3/a")[0]["href"]
      @data << tpl
    end
  end

end

LiquidRoomParser.start