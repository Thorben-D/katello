module Actions
  module Katello
    module Repository
      class CloneYumContent < Actions::Base
        # rubocop:disable MethodLength
        # rubocop:disable Metrics/CyclomaticComplexity TODO: refactor to push everything into options hash
        # rubocop:disable Metrics/PerceivedComplexity
        def plan(source_repo, target_repo, filters, options = {})
          generate_metadata = options.fetch(:generate_metadata, true)
          index_content = options.fetch(:index_content, true)
          rpm_filenames = options.fetch(:rpm_filenames, {})
          purge_empty_units = options.fetch(:purge_empty_units, {})

          copy_clauses = nil
          remove_clauses = nil
          process_errata_and_groups = false
          filters = filters.yum unless filters.is_a? Array

          if filters.any?
            clause_gen = ::Katello::Util::PackageClauseGenerator.new(source_repo, filters)
            clause_gen.generate
            copy_clauses = clause_gen.copy_clause
            remove_clauses = clause_gen.remove_clause
          end

          # if we are providing a list of files, process that here and override filters
          if rpm_filenames.present?
            # log a warning if we are overriding the list of RPMs and using a filter
            # ensure we have all the files we want to copy
            rpms_available = source_repo.rpms.pluck(:filename)
            rpm_filenames.each do |filename|
              fail "%s not available in repository %s" % [filename, source_repo.label] unless rpms_available.include? filename
            end
            copy_clauses = { 'filename' => { '$in' => rpm_filenames } }
            remove_clauses = nil
            Rails.logger.warn("Filters on content view have been overridden by passed-in filename list during publish") if filters.any?
          end

          sequence do
            plan_copy(Pulp::Repository::CopySrpm, source_repo, target_repo)

            if filters.empty? || copy_clauses
              plan_copy(Pulp::Repository::CopyRpm, source_repo, target_repo, copy_clauses)
              process_errata_and_groups = true
            elsif options[:simple_clone]
              plan_copy(Pulp::Repository::CopyRpm, source_repo, target_repo)
              process_errata_and_groups = true
            end
            if remove_clauses
              plan_remove(Pulp::Repository::RemoveRpm, target_repo, :unit => remove_clauses)
              process_errata_and_groups = true
            end
            if process_errata_and_groups
              plan_copy(Pulp::Repository::CopyErrata, source_repo, target_repo, nil)
              plan_copy(Pulp::Repository::CopyPackageGroup, source_repo, target_repo, nil)
            end
            plan_copy(Pulp::Repository::CopyYumMetadataFile, source_repo, target_repo)
            plan_copy(Pulp::Repository::CopyDistribution, source_repo, target_repo)
            plan_copy(Pulp::Repository::CopyModuleStream, source_repo, target_repo, nil)
            plan_copy(Pulp::Repository::CopyModuleDefault, source_repo, target_repo)

            # Check for matching content before indexing happens, the content in pulp is
            # actually updated, but it is not reflected in the database yet.
            output = {}
            if target_repo.environment && !options[:force_yum_metadata_regeneration]
              output = plan_action(Katello::Repository::CheckMatchingContent,
                                   :source_repo_id => source_repo.id,
                                   :target_repo_id => target_repo.id).output
            end

            plan_action(Katello::Repository::IndexContent, id: target_repo.id) if index_content

            if purge_empty_units
              plan_action(Pulp::Repository::PurgeEmptyErrata, :pulp_id => target_repo.pulp_id)
              plan_action(Pulp::Repository::PurgeEmptyPackageGroups, :pulp_id => target_repo.pulp_id)
              plan_action(Katello::Repository::IndexErrata, target_repo)
              plan_action(Katello::Repository::IndexPackageGroups, target_repo)
            end

            source_repository = filters.empty? && rpm_filenames.empty? ? source_repo : nil

            if generate_metadata
              plan_action(Katello::Repository::MetadataGenerate,
                          target_repo,
                          :source_repository => source_repository,
                          :matching_content => output[:matching_content])
            end
          end
        end

        def plan_copy(action_class, source_repo, target_repo, clauses = nil)
          plan_action(action_class,
                      source_pulp_id: source_repo.pulp_id,
                      target_pulp_id: target_repo.pulp_id,
                      clauses:        clauses)
        end

        def plan_remove(action_class, target_repo, clauses)
          plan_action(action_class,
                      pulp_id:        target_repo.pulp_id,
                      clauses:        clauses)
        end
      end
    end
  end
end
