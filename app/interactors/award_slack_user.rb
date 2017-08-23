class AwardSlackUser
  include Interactor::Organizer

  organize ProjectTokensIssued, BuildAwardRecords
end
