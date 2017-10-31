class Views::Shared::EmailFooter < Views::EmailBase
  def content
    full_row(class: :footer) {
      td(class: 'text-pad') {
        p 'Disclosures'
        p '...'
      }
    }

    full_row {
      center_td {
        div raw("&copy; #{Date.current.year} #{I18n.t('company_name')} All Rights Reserved.")
      }
    }
  end
end
