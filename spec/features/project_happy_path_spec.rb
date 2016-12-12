require "rails_helper"

describe "viewing projects, creating and editing", :js do
  let!(:project) { create(:project, title: "Cats with Lazers Project", description: "cats with lazers", owner_account: account, slack_team_id: "citizencode", public: false) }
  let!(:public_project) { create(:project, title: "Public Project", description: "dogs with donuts", owner_account: account, slack_team_id: "citizencode", public: true) }
  let!(:public_project_award_type) { create(:award_type, project: public_project) }
  let!(:public_project_award) { create(:award, award_type: public_project_award_type, created_at: Date.new(2016, 1, 9)) }
  let!(:account) { create(:account, email: "gleenn@example.com").tap { |a| create(:authentication, account_id: a.id, slack_team_id: "citizencode", slack_team_domain: "citizencodedomain", slack_team_name: "Citizen Code", slack_team_image_34_url: "https://slack.example.com/awesome-team-image-34-px.jpg", slack_team_image_132_url: "https://slack.example.com/awesome-team-image-132-px.jpg", slack_user_name: 'gleenn', slack_first_name: "Glenn", slack_last_name: "Spanky") } }
  let!(:same_team_account) { create(:account, ethereum_wallet: "0x#{'1'*40}") }
  let!(:same_team_account_authentication) { create(:authentication, account: same_team_account, slack_team_id: "citizencode", slack_team_name: "Citizen Code") }
  let!(:other_team_account) { create(:account).tap { |a| create(:authentication, account_id: a.id, slack_team_id: "comakery", slack_team_name: "CoMakery") } }

  before do
    Rails.application.config.allow_ethereum = 'citizencodedomain'
    travel_to Date.new(2016, 1, 10)
    stub_slack_user_list
    stub_slack_channel_list
  end

  it "does the happy path" do
    login(account)

    visit projects_path

    expect(page).to have_content "Cats with Lazers Project"

    within "#project-#{project.to_param}" do
      click_link project.title
    end

    visit projects_path

    click_link "New Project"

    fill_in "Description", with: "This is a project description which is very informative"
    fill_in "Project Owner's Legal Name", with: "Mindful Inc"

    attach_file "Project Image", Rails.root.join("spec", "fixtures", "helmet_cat.png")
    expect(find_field("Set project as public")).not_to be_checked

    expect(find_field("Maximum Awards")['value']).to eq("12000")
    fill_in "Maximum Awards", with: "20000000"

    award_type_inputs = get_award_type_rows
    expect(award_type_inputs.size).to eq(3)
    award_type_inputs[0].all("input")[0].set "This is a small award type"
    award_type_inputs[0].all("input")[1].set "1000"
    award_type_inputs[1].all("input")[0].set "This is a medium award type"
    award_type_inputs[1].all("input")[1].set "2000"
    award_type_inputs[2].all("input")[0].set "This is a large award type"
    award_type_inputs[2].all("input")[1].set "3000"
    # award_type_inputs[3]["class"].include?("hide")

    click_link "+ add award type"

    award_type_inputs = get_award_type_rows
    expect(award_type_inputs.size).to eq(4)

    award_type_inputs[3].find("input[name*='[name]']").set "This is a super big award type"
    award_type_inputs[3].find("input[name*='[amount]']").set "5000"

    click_link "+ add award type"

    award_type_inputs = get_award_type_rows
    expect(award_type_inputs.size).to eq(5)

    click_remove(award_type_inputs.last)

    award_type_inputs = get_award_type_rows
    expect(award_type_inputs.size).to eq(4)

    click_on "Save"

    expect(page).to have_content "Title can't be blank"
    expect(page).to have_content "Slack Channel can't be blank"

    fill_in "Title", with: "This is a project"
    select "a-channel-name", from: "Slack Channel"

    select "Royalties paid in US Dollars ($)", from: "Award Payment Type"

    fill_in "Percentage of Revenue reserved", with: "7.99999"
    fill_in "Maximum Awarded Per Quarter", with: "25000"
    fill_in "Minimum Revenue Collected ", with: "150"
    fill_in "Contributor Minimum Payment", with: "26"

    click_on "Save"

    expect(page).to have_content "Project created"
    expect(page).to have_content "This is a project"
    expect(page).to have_content "This is a project description"
    expect(page.find(".project-image")[:src]).to match(%r{/attachments/[A-Za-z0-9/]+/image})
    expect(page).not_to have_link "Project Tasks"

    expect(page).to have_content "Maximum Royalties: $20,000,000"
    expect(page).to have_content "$0 awarded"
    expect(page).to have_content "$0 mine"

    expect(page).to have_content "Lead by Glenn Spanky"
    expect(page).to have_content "Citizen Code"

    award_type_rows = get_award_type_rows
    expect(Project.last.award_types.count).to eq(4)
    expect(award_type_rows.size).to eq(4)

    expect(award_type_rows[0]).to have_content "This is a small award type"
    expect(award_type_rows[0]).to have_content "1,000"

    expect(award_type_rows[1]).to have_content "This is a medium award type"
    expect(award_type_rows[1]).to have_content "2,000"

    expect(award_type_rows[2]).to have_content "This is a large award type"
    expect(award_type_rows[2]).to have_content "3,000"

    expect(award_type_rows[3]).to have_content "This is a super big award type"
    expect(award_type_rows[3]).to have_content "5,000"

    click_on "Edit"

    expect(page.find(".project-image")[:src]).to match(%r{/attachments/[A-Za-z0-9/]+/image})

    expect(page).to have_unchecked_field("Set project as public")
    fill_in "Title", with: "This is an edited project"
    fill_in "Description", with: "This is an edited project description which is very informative"
    fill_in "Project Tracker", with: "http://github.com/here/is/my/tracker"
    fill_in "Video", with: "https://www.youtube.com/watch?v=Dn3ZMhmmzK0"
    uncheck "Set project as public"
    uncheck "Publish to Ethereum Blockchain"

    award_type_inputs = get_award_type_rows
    expect(award_type_inputs.size).to eq(4)

    award_type_inputs[0].all("a[data-mark-and-hide]")[0].click
    award_type_inputs[1].find("input[name*='[community_awardable]']").set(true)
    award_type_inputs = get_award_type_rows
    expect(award_type_inputs.size).to eq(3)

    # youtube player throws js errors, ignore them:
    ignore_js_errors { click_on "Save" }
    ignore_js_errors { expect(page).to have_content "Project updated" }

    expect(EthereumTokenContractJob.jobs.length).to eq(0)
    expect(EthereumTokenIssueJob.jobs.length).to eq(0)

    expect(page).to have_content "This is an edited project"
    expect(page).to have_content "This is an edited project description which is very informative"
    expect(page).to have_link "Project Tasks"
    expect(page).to have_link "Slack Channel", href: "https://citizencodedomain.slack.com/messages/a-channel-name"
    expect(page.all(".project-video iframe").size).to eq(1)

    award_type_inputs = get_award_type_rows
    expect(award_type_inputs.size).to eq(3)
    expect(page).to have_content "This is a medium award type ($2,000) (Community Awardable)"
    expect(page).not_to have_content "This is a small award type"
    expect(page).not_to have_content "1,000"

    expect(award_type_inputs.size).to eq(3)

    visit("/projects")

    expect(page).to have_content "This is an edited project"

    login(same_team_account)

    visit("/projects")

    expect(page).to have_content "This is an edited project"

    login(other_team_account)

    visit("/projects")

    expect(page).not_to have_content "This is an edited project"

    expect(page).to have_content "Public Project"

    click_link "Public Project"

    expect(page).not_to have_content "Edit"
  end

  describe "removing award types on projects where there have been awards sent already" do
    let!(:project) { create(:project, title: "Cats with Lazers Project", description: "cats with lazers", owner_account: account, slack_team_id: "citizencode", public: false, slack_channel: "a-channel-name") }
    before { login(account) }

    let!(:award_type) { create(:award_type, project: project, name: "Big ol' award", amount: 40000, community_awardable: false) }

    context "without awards" do
      it "can update any attribute" do
        visit edit_project_path(project)
        award_type_amount_input = page.find("input[name*='[amount]']")

        expect(page.all("a[data-mark-and-hide]").size).to eq(1)
        expect(award_type_amount_input[:value]).to eq("40000")
        expect(award_type_amount_input[:readonly]).to be_falsey

        award_type_amount_input.set("50000")
        page.find("input[name*='[title]']").set("fancy title")
        page.find("input[name*='[community_awardable]']").set(true)

        click_on "Save"

        visit edit_project_path(project)
        award_type_amount_input = page.find("input[name*='[amount]']")

        expect(award_type_amount_input[:value]).to eq("50000")
        expect(award_type_amount_input[:readonly]).to be_falsey
        expect(page.find("input[name*='[title]']")[:value]).to eq("fancy title")
        expect(page.find("input[name*='[community_awardable]']")).to be_truthy
      end
    end

    context "with awards" do
      let!(:award) { create(:award, award_type: award_type, authentication: same_team_account_authentication) }

      it "prevents destroying the award types" do
        visit edit_project_path(project)
        award_type_amount_input = page.find("input[name*='[amount]']")

        expect(page.all("a[data-mark-and-hide]").size).to eq(0)
        expect(page).to have_content "(1 award sent)"
        expect(award_type_amount_input[:value]).to eq("40000")
        expect(award_type_amount_input[:readonly]).to eq("readonly")
      end

      it "allows modifying the award type's name and community awardable but NOT amount" do
        visit edit_project_path(project)

        page.find("input[name*='[title]']").set("fancy title")
        page.find("input[name*='[community_awardable]']").set(true)

        click_on "Save"

        visit edit_project_path(project)

        expect(page.find("input[name*='[title]']")[:value]).to eq("fancy title")
        expect(page.find("input[name*='[community_awardable]']")[:value]).to be_truthy
      end

      it "allows creating ethereum contract for project AND ethereum tokens for each award" do
        award2 = create(:award, award_type: award_type, authentication: same_team_account_authentication)
        visit edit_project_path(project)
        check "Publish to Ethereum Blockchain"
        click_on "Save"

        expect(EthereumTokenContractJob.jobs.length).to eq(1)
        expect(EthereumTokenContractJob.jobs.first['args'].first).to eq(project.id)

        expect(EthereumTokenIssueJob.jobs.length).to eq(2)
        expect(EthereumTokenIssueJob.jobs.map{ |job| job['args'] }.flatten).to match_array([
          award.id, award2.id ])

      end
    end
  end

  it "shows the percentage of coin awards if greater than 0.01% have been awarded" do
    login(account)

    visit project_path(project)

    within(".awarded-info") do
      expect(page).to have_content "$0 awarded"
      expect(page).to have_content "$0 mine"
    end

    create(:award, award_type: create(:award_type, project: project, amount: 100_000))

    visit project_path(project)

    within(".awarded-info") do
      expect(page).to have_content "$100,000 (1.00%) awarded"
      expect(page).to have_content "$0 mine"
    end
  end
end
