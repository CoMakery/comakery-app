class UpdateProjectVisibility < ActiveRecord::Migration[5.1]
  def change
    public_projects = Project.where(public: true)
    private_projects = Project.where.not(public: true)
    public_projects.each do |p|
      p.public_listed!
    end
    private_projects.each do |p|
      p.member!
    end
    remove_column :projects, :archived, :boolean
  end
end
