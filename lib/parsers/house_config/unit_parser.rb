class UnitParser < ScheduleParser
  def parse_init
    @uri =
      "http://www.unit-tokyo.com/schedule/#{@@now.year}/#{'%02d' % @@now.mon}/live_schedule.php"
    return Nokogiri::HTML(open(@uri))
  end

  def get_descriptions
    (@doc/"//td[@class='td_cal']").each do |elm|
      tpl = {}
      tpl[:house_id] = 9
      day = (elm/"div").first.inner_text.to_i
      tpl[:ym] = @@now.strftime("%Y%m")
      tpl[:date] = Date.new(@@now.year, @@now.mon, day)

      info_elm = elm.next_element
      title_elm = (info_elm/".event_title_live")
      title_elm = (info_elm/".event_title_club") if title_elm.empty?
      tpl[:title] = title_elm.inner_text.gsub(/\n/, " ").strip

      tpl[:desc] = "#{(info_elm/".event_line_up").inner_text.gsub(/\n/, " ").strip}\n" +
                   "#{(info_elm/".event_info").inner_text.gsub(/\n/, " ").strip}"

      tpl[:permlink] = (title_elm/"a")[0]["href"]
      @data << tpl
    end
  end

end

UnitParser.start