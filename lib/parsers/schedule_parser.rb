require "rubygems"
require 'mysql'
require "hpricot"
require "nokogiri"
require "open-uri"
require "kconv"

class ScheduleParser
  @uri = ""
  @doc = nil
  @date_axis = nil
  @data = []

  @@db = nil
  @@now = nil

  def initialize(now=nil)
    case now
    when nil
      @@now
    when String
      @@now = Date.parse(now)
    when Date
      @@now = now
    end
    @data = []
    @doc = parse_init
    get_descriptions
    insert_data
  end

  def parse_init
    Hpricot(open(@uri))
  end

  def get_descriptions
    nil
  end

  def insert_data
    @data.map! do |tpl|
      "(NULL,
        '#{tpl[:ym]}',
        '#{tpl[:date]}',
        '#{tpl[:house_id]}',
        '#{@@db.quote tpl[:title]}',
        '#{@@db.quote tpl[:desc]}',
        '#{@@db.quote tpl[:permlink]}',
        NOW(),
        NOW())"
    end
    puts @data.join(', ')[0..1000], "......"
    @@db.query(
      "INSERT INTO schedules(
        `id`,
        `ym`,
        `date`,
        `live_house_id`,
        `title`,
        `desc`,
        `permlink`,
        `created_at`,
        `updated_at`
      )
      VALUES
      #{@data.join(', ')}"
    )
    puts "MySQL: #{@@db.affected_rows} line(s) inserted"
  end

  def self.start(*args)
    self.new(*args)
  end

  def self.db=(mydb)
    @@db = mydb
  end

  def self.now=(the_time)
    @@now = the_time
  end
end