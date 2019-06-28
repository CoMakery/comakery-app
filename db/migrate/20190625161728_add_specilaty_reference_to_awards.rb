class AddSpecilatyReferenceToAwards < ActiveRecord::Migration[5.1]
  def change
    add_reference :awards, :specialty, foreign_key: true
  end
end
