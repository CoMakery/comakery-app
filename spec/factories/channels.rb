FactoryBot.define do
  factory :channel do
    project
    team
    channel_id { Faker::Internet.uuid }
    name { Faker::Lorem.word }

    trait(:slack) do
      name { :slack }
      channel_id { :slack_uid }
      team do |channel|
        team = FactoryBot.create(:team, :slack)
        auth = FactoryBot.create(:authentication, :slack, account: channel.project.account)
        FactoryBot.create(:authentication_team, account: channel.project.account, team: team, authentication: auth)
        team
      end
    end

    trait(:discord) do
      name { :discord }
      channel_id { :discord_uid }
      team do |channel|
        team = FactoryBot.create(:team, :discord)
        auth = FactoryBot.create(:authentication, :discord, account: channel.project.account)
        FactoryBot.create(:authentication_team, account: channel.project.account, team: team, authentication: auth)
        team
      end
    end
  end
end
