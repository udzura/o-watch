#!/usr/bin/ruby
# Parser Batch Job

require 'parsers/schedule_parser'
require 'yaml'

RAILS_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../..") unless defined?(RAILS_ROOT)
PARSER_CONFIG_DIR = File.join(RAILS_ROOT, "lib", "parsers", "house_config")

now = ARGV.empty? ? Date.today >> 1 : Date.parse(ARGV[0])
production_db_config = YAML.load_file(File.join(RAILS_ROOT, "config", "database.yml"))["development"]
db = ::Mysql.init.
    options(Mysql::SET_CHARSET_NAME, "utf8").
    real_connect(
      "localhost",
      production_db_config["username"],
      production_db_config["password"],
      production_db_config["database"]
    )
db.query(
  "DELETE FROM schedules
   WHERE `ym` = '#{now.strftime('%Y%m')}'"
)
puts "MySQL: #{db.affected_rows} line(s) truncated"

ScheduleParser.db = db
ScheduleParser.now = now

puts "Setting Directory is: #{PARSER_CONFIG_DIR}"
Dir.glob(PARSER_CONFIG_DIR + "/[lqu]*").each do |fname|
  puts "Loading: #{File.basename(fname)}"
  load fname
  puts "Loading Success!!: #{File.basename(fname)}"
end

db.close
puts "Done: #{now.strftime("%Y/%m")}"
