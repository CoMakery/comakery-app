class Views::Authentications::Show < Views::Base
  needs :authentication, :awards

  def content
    awards.group_by{|award|award.award_type.project_id}.each do |(_, awards_for_project)|
      h3 "#{awards_for_project.first.award_type.project.title} awards"
      render partial: "shared/awards", locals: {awards: awards_for_project, show_recipient: false}
    end
  end
end