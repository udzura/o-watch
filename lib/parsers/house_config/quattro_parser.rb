class QuattroParser < ScheduleParser
  def parse_init
    @uri =
      "http://www.club-quattro.com/schedule_shib.php?year=#{@@now.year}&month=#{'%02d' % @@now.mon}"
    return super
  end

  def get_descriptions
    (@doc/"//td[@width='70']/span[@class='txt12_140_333']").each do |elm|
      tpl = {}
      tpl[:house_id] = 5
      day = elm.inner_text.match(/#{@@now.mon}\/(\d{1,2})/)[1].to_i
      tpl[:ym] = @@now.strftime("%Y%m")
      tpl[:date] = Date.new(@@now.year, @@now.mon, day)

      d_tmp = (elm/"../../../tr/td[3]/span")[0].
               children.map(&:inner_text).delete_if(&:empty?)
      tpl[:title] = d_tmp.shift.toutf8

      t_open = (elm/"../../../tr/td")[3].inner_text.strip
      t_start = (elm/"../../../tr/td")[4].inner_text.strip
      tpl[:desc] = "#{d_tmp.join("\n").toutf8}\nOPEN: #{t_open} / START: #{t_start}"

      post_path = (elm/"../../../tr/td[3]//a")[0]["href"]
      tpl[:permlink] = "http://#{URI(@uri).host}/#{post_path}"
      @data << tpl
    end
  end

end

QuattroParser.start