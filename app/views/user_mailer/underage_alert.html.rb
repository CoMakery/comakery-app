class Views::UserMailer::UnderageAlert < Views::Base
  needs :account, :old_age
  def content
    row {
      p {
        text "Name: #{account.decorate.name}"
        br
        text "Email: #{account.email}"
      }
      p {
        text "This user may be underage. They set their age to #{old_age} then they changed their age to #{account.age}. They may be younger than our minimum age of 16 for compliance with Children's Online Privacy Protection Act (COPPA) and the Fair Labor Standards Act (FLSA)."
      }
    }
  end
end
