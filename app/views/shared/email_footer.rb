class Views::Shared::EmailFooter < Views::EmailBase
  def content
    full_row(class: :footer) do
      td(class: 'text-pad') do
        p 'Disclosures'
        p '...'
      end
    end

    full_row do
      center_td do
        div raw("&copy; #{Date.current.year} #{Rails.application.config.company_name} All Rights Reserved.")
      end
    end
  end
end
