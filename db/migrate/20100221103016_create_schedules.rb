class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.string :ym
      t.date :date
      t.integer :live_house_id
      t.string :title
      t.text :desc
      t.string :permlink

      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
