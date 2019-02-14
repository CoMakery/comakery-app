```plantuml
@startuml task-states
hide empty description

state "My Tasks" as Started {
    [*] --> Pending : Admin\nCreates Task
    Pending -right-> Available  : Admin\nInvites and/or Publishes
    Available -down-> InProgress : A Worker\nClaims Task
    InProgress -right-> Available: Worker\nQuits Task
    InProgress -right-> Expired: max time exceeded
    Expired: Inform Worker
    Expired: Inform Project Admin
    Expired -left-> InProgress : Admin extends
    Expired -up-> Available: Admin\nInvites and/or Publishes
}

state "Task Review" as Review {
    InProgress -down-> ReadyForReview: Worker\nSubmits Work
    ReadyForReview -up-> InProgress: Reviewer\nRequests Changes
    ReadyForReview -right-> Reviewed: Reviewer\nAccepts
    Reviewed -right-> [*]: Admin Pays Via Crypto Wallet
}

@enduml
```

```plantuml
@startuml task-activity
|Admin|
start
partition "Task Creation Page" {
    :Create Task;
    :Set Award;
}

repeat
partition "Invitation Page" {
    :Invite Workers To Task;
    :Invite Reviewers To Task;
    :Publish Task\nFor Worker & Reviewer\nMatches;
}
partition "My Tasks Page" {
    |#AntiqueWhite|Worker|
    |Worker|
    :Claim Task;
}
    repeat
    partition "My Tasks Page" {
        |#AntiqueWhite|Worker|
        |Worker|
        :Submit Work;
    }
    partition "My Tasks Page" {
        |Reviewer|
        :Review Work;
    }
    repeat while (changes\nrequested?) is (yes)
    partition "My Tasks Page" {
        |Admin|
        :Final Review;
        :Pay Reviewer\n(next iteration);
    }

repeat while (rejected?) is (yes)
partition "My Tasks Page" {
    |Admin|
    :Pay Worker;
}
stop
@enduml
```