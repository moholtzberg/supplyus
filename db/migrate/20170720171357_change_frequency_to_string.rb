class ChangeFrequencyToString < ActiveRecord::Migration
  def change
    
    def self.up
      change_column :subscriptions, :frequency, :string
    end
    
    def self.down
      change_column :subscriptions, :frequency, :integer
    end
    
  end
end
