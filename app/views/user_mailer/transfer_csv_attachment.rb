class Views::UserMailer::TransferCsvAttachment < Views::Base
  needs :project
  def content
    row do
      p do
        text "You have received transfers's file of '#{project.title}' project in the attachment"
      end
    end
  end
end
