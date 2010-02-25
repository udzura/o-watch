class CreateLiveHouses < ActiveRecord::Migration
  def self.up
    create_table :live_houses do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :live_houses
  end
end
