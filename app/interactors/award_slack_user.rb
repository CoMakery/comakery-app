class AwardSlackUser
  include Interactor::Organizer

  organize ProjectCoinsIssued, BuildAwardRecords
end