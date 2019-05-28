class AddSubmissionColumnsToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :submission_url, :string
    add_column :awards, :submission_comment, :string
  end
end
