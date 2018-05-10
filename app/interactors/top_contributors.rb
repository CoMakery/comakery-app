class TopContributors
  include Interactor

  def call
    projects = context.projects
    n = context.n || 5

    contributors = projects.each_with_object({}) do |project, projects_to_contributors|
      projects_to_contributors[project] = top_contributors(project, n)
    end

    context.contributors = contributors
  end

  def top_contributors(project, n)
    all_columns = (Account.column_names - %w[password_digest public_address nonce network_id system_email]).map { |column| "max(accounts.#{column}) as #{column}" }.join(', ')
    Account
      .select("#{all_columns}, sum(award_total_amount) as total_awarded, max(last_awarded_at) as last_awarded_at")
      .from(project.contributors
            .select("#{all_columns}, sum(awards.total_amount) as award_total_amount, max(awards.created_at) as last_awarded_at")
            .group('accounts.id, award_types.id'),
        'accounts')
      .group('accounts.id')
      .order('total_awarded desc, max(last_awarded_at) desc')
      .limit(n)
      .to_a
  end
end
