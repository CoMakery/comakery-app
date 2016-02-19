require 'rails_helper'

describe ProjectPolicy do
  describe ProjectPolicy::Scope do
    describe "#resolve" do
      it "returns all public projects and projects that belong to the current user" do
        account = create(:account)
        owned_project = create(:project, title: "owned", owner_account: account)
        public_project = create(:project, title: "public", owner_account: account)
        private_project = create(:project, title: "private", owner_account: account, public: false)

        somebody_else = create(:account)
        private_someone_elses_project = create(:project, title: "private someone elses", owner_account: somebody_else, public: false)

        projects = ProjectPolicy::Scope.new(account, Project).resolve

        expect(projects.sort_by(&:title).to_a).to eq([owned_project, private_project, public_project])
      end
    end
  end
end
