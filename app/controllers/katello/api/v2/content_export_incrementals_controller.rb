module Katello
  class Api::V2::ContentExportIncrementalsController < Api::V2::ApiController
    before_action :fail_if_not_pulp3, :only => [:version, :library]
    before_action :find_exportable_organization, :only => [:library]
    before_action :find_exportable_content_view_version, :only => [:version]
    before_action :find_library_export_view, :only => [:library]
    before_action :find_history, :only => [:version, :library]

    api :POST, "/content_export_incrementals/version", N_("Performs an incremental-export of a content view version.")
    param :id, :number, :desc => N_("Content view version identifier"), :required => true
    param :destination_server, String, :desc => N_("Destination Server name"), :required => false
    param :chunk_size_mb, :number, :desc => N_("Split the exported content into archives "\
                                               "no greater than the specified size in megabytes."), :required => false
    param :from_history_id, :number, :desc => N_("Export history identifier used for incremental export. "\
                                                 "If not provided the most recent export history will be used."), :required => false
    param :fail_on_missing_content, :bool, :desc => N_("Fails if any of the repositories belonging to this version"\
                                                         " are unexportable. False by default."), :required => false
    def version
      tasks = async_task(::Actions::Pulp3::Orchestration::ContentViewVersion::Export,
                          content_view_version: @version,
                          destination_server: params[:destination_server],
                          chunk_size: params[:chunk_size_mb],
                          from_history: @history,
                          fail_on_missing_content: ::Foreman::Cast.to_bool(params[:fail_on_missing_content]))

      respond_for_async :resource => tasks
    end

    api :POST, "/content_export_incrementals/library", N_("Performs an incremental-export of the repositories in library.")
    param :organization_id, :number, :desc => N_("Organization identifier"), :required => true
    param :destination_server, String, :desc => N_("Destination Server name"), :required => false
    param :chunk_size_mb, :number, :desc => N_("Split the exported content into archives "\
                                               "no greater than the specified size in megabytes."), :required => false
    param :from_history_id, :number, :desc => N_("Export history identifier used for incremental export. "\
                                                 "If not provided the most recent export history will be used."), :required => false
    param :fail_on_missing_content, :bool, :desc => N_("Fails if any of the repositories belonging to this organization"\
                                                         " are unexportable. False by default."), :required => false
    def library
      tasks = async_task(::Actions::Pulp3::Orchestration::ContentViewVersion::ExportLibrary,
                          @organization,
                          destination_server: params[:destination_server],
                          chunk_size: params[:chunk_size_mb],
                          from_history: @history,
                          fail_on_missing_content: ::Foreman::Cast.to_bool(params[:fail_on_missing_content]))
      respond_for_async :resource => tasks
    end

    private

    def find_exportable_content_view_version
      @version = ContentViewVersion.exportable.find_by_id(params[:id])
      throw_resource_not_found(name: 'content view version', id: params[:id]) if @version.blank?
      @view = @version.content_view
    end

    def find_library_export_view
      @view = ::Katello::Pulp3::ContentViewVersion::Export.find_library_export_view(destination_server: params[:destination_server],
                                                                organization: @organization,
                                                                create_by_default: false)
      if @view.blank?
        msg = _("Unable to incrementally export. Do a Full Export on the library content "\
                "before updating from the latest increment.")
        fail HttpErrors::BadRequest, msg
      end
    end

    def find_history
      if params[:from_history_id].present?
        @history = ::Katello::ContentViewVersionExportHistory.find(params[:from_history_id])
        if @history.blank?
          throw_resource_not_found(name: 'export history',
                                   id: params[:from_history_id])
        end
      else
        @history = ::Katello::ContentViewVersionExportHistory.
                      latest(@view,
                                          destination_server: params[:destination_server])
        if @history.blank?
          msg = _("No existing export history was found to perform an incremental export. A full export must be performed")
          fail HttpErrors::NotFound, msg
        end
      end
    end

    def find_exportable_organization
      find_organization
      unless @organization.can_export_library_content?
        throw_resource_not_found(name: 'organization', id: params[:organization_id])
      end
    end

    def fail_if_not_pulp3
      unless SmartProxy.pulp_primary.pulp3_repository_type_support?(Katello::Repository::YUM_TYPE)
        fail HttpErrors::BadRequest, _("Invalid usage for Pulp 2 repositories. Use export for Yum repositories")
      end
    end
  end
end
