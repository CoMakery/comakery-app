require 'rails_helper'

describe ProjectPolicy do
  let!(:account) { create(:account) }
  let!(:my_public_project) { create(:project, title: "public mine", owner_account: account, public: true) }
  let!(:my_private_project) { create(:project, title: "private mine", owner_account: account, public: false) }

  let!(:other_account) { create(:account) }
  let!(:others_public_project) { create(:project, title: "public someone elses", owner_account: other_account, public: true) }
  let!(:others_private_project) { create(:project, title: "private someone elses", owner_account: other_account, public: false) }

  describe ProjectPolicy::Scope do
    describe "#resolve" do
      it "returns all public projects and projects that belong to the current user" do
        projects = ProjectPolicy::Scope.new(account, Project).resolve

        expect(projects.sort_by(&:title).to_a).to eq([my_private_project, my_public_project, others_public_project])
      end
    end
  end

  describe "#show? #edit? #update?" do
    it "only allows viewing of projects that are public or are owned by the current account" do
      [:show?, :edit?, :update?].each do |action|
        expect(ProjectPolicy.new(nil, my_public_project).send(action)).to be false
        expect(ProjectPolicy.new(account, my_public_project).send(action)).to be true
        expect(ProjectPolicy.new(account, my_private_project).send(action)).to be true
        expect(ProjectPolicy.new(other_account, others_public_project).send(action)).to be true
        expect(ProjectPolicy.new(account, others_private_project).send(action)).to be false
      end
    end
  end
end
