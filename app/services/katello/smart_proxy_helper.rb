module Katello
  class SmartProxyHelper
    attr_accessor :smart_proxy
    def initialize(smart_proxy)
      @smart_proxy = smart_proxy
    end

    def ==(other)
      other.class == self.class && other.smart_proxy == smart_proxy
    end

    def default_capsule?
      @smart_proxy.pulp_primary?
    end

    def lifecycle_environment_check(environment = nil, repository = nil)
      environment = repository.environment if repository

      if environment && !self.smart_proxy.lifecycle_environments.include?(environment)
        fail _("Lifecycle environment '%{environment}' is not attached to this capsule.") % { :environment => environment.name }
      end
    end

    def clear_smart_proxy_sync_histories(repo_list = [])
      if repo_list.empty?
        @smart_proxy.smart_proxy_sync_histories.delete_all
        return
      end
      repo_ids = repo_list.map(&:id)
      @smart_proxy.smart_proxy_sync_histories.where("repository_id IN (?)", repo_ids).delete_all
    end

    def combined_repos_available_to_capsule(environment = nil, content_view = nil, repository = nil)
      lifecycle_environment_check(environment, repository)
      if repository
        [repository]
      else
        repositories_available_to_capsule(environment, content_view)
      end
    end

    def repositories_available_to_capsule(environments, content_view)
      environments = @smart_proxy.lifecycle_environments if environments.nil?
      yum_repos = Katello::Repository.in_environment(environments)
      yum_repos = yum_repos.in_content_views([content_view]) if content_view
      yum_repos.smart_proxy_syncable
    end
  end
end
