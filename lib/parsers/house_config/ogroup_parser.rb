class OGroupParser < ScheduleParser
  def parse_init
    ret = []
    @houses = ["East", "West", "Nest", "Crest"]
    @uri2 ||= []
    @houses.each_with_index do |house, i|
      @uri =
        "http://shibuya-o.com/category/#{house.downcase}/?id=schedule&Year=#{@@now.year}&Month=#{@@now.mon}"
      ret << Hpricot(open(@uri))
      @uri2[i] = @uri.dup
    end
    ret
  end

  def get_descriptions
    @doc.each_with_index do |doc, i|
      (doc/".scheduledate").each do |elm|
        tpl = {}
        tpl[:house_id] = i + 1
        day = elm.inner_text.split[0].match(/#{"%02d" % @@now.mon}\/(\d\d)/)[1].to_i
        tpl[:ym] = @@now.strftime("%Y%m")
        tpl[:date] = Date.new(@@now.year, @@now.mon, day)
        tpl[:title] = (elm/"../../../td/span[@class='scheduletitle']").inner_text.strip
        tpl[:desc] = (elm/"../../../td/p")[1..4].map{|v| v.inner_text.strip}.join("\n")
        post_id = (elm/"../../../td/span[@class='scheduletitle']")[0]["id"]
        tpl[:permlink] = "#{@uri2[i]}##{post_id}"
        @data << tpl
      end
    end
  end

end

OGroupParser.start