module ApplicationHelper
  include Turbo::FramesHelper
  include Turbo::StreamsHelper

  def account_image_url(account, size)
    GetImageVariantPath.call(
      attachment: account&.image,
      resize_to_fill: [size, size],
      fallback: asset_url('user-icon.svg')
    ).path
  end

  def project_image_url(obj, size)
    GetImageVariantPath.call(
      attachment: obj&.square_image,
      resize_to_fill: [size, size],
      fallback: asset_url('default_project.jpg')
    ).path
  end

  def project_page
    if controller_name == 'projects'
      params[:action]
    else
      controller_name
    end
  end

  def ransack_filter_present?(query, name, predicate, value) # rubocop:todo Metrics/CyclomaticComplexity
    query.conditions.any? do |c|
      return false unless c.predicate.name == predicate
      return false unless c.attributes.any? { |a| a.name == name }
      return false unless c.values.any? { |v| v.value == value }

      true
    end
  end

  def transfer_type(transfer_type_id)
    TransferType.find(transfer_type_id)
  end

  def transfers_totals_data(transfers_totals)
    { total_transfers: transfers_totals.size,
      total_accounts: transfers_totals.pluck(:account_id).uniq.size,
      total_admins: transfers_totals.paid.pluck(:issuer_id).uniq.size,
      total_quantity: transfers_totals.sum(&:quantity),
      total_amount: transfers_totals.sum(&:total_amount) }
  end

  def transfer_account(account_id)
    Account.includes(:ore_id_account).find_by(id: account_id)
  end

  def middle_truncate(str, length: 5)
    str.truncate(length, omission: "#{str.first(length)}...#{str.last(length)}")
  end

  def flash_to_array
    %i[notice warning error].map do |severity|
      flash[severity] ? { severity: severity, text: html_escape(flash[severity]) } : nil
    end.compact
  end
end
