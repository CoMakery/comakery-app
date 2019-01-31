class AddTokenIdToMissions < ActiveRecord::Migration[5.1]
  def change
    add_reference :missions, :token, index: true
  end
end
