# require 'active_admin/reloader'

module ActionBlocks
  class Loader

    attr_reader :application, :load_paths
    def initialize(path)
      @load_paths = [File.expand_path(path, Rails.root)]
      # puts "ActionBlocks @load_path=#{@load_paths.inspect}"
    end

    # Whether all configuration files have been loaded
     def loaded?
       @@loaded ||= false
     end

     # Removes all defined controllers from memory. Useful in
     # development, where they are reloaded on each request.
     def unload!
       ActionBlocks.unload!
       @@loaded = false
     end

     # Loads all ruby files that are within the load_paths setting.
     # To reload everything simply call `ActionBlocks.unload!`
     def load!(force=false)
       # puts "ActionBlocks @load_path=#{@load_paths.inspect}"

       Rails.logger.debug "ActionBlocks::Loader load!()"
       Rails.logger.debug " loaded?:#{loaded?().inspect}"
       unless loaded? && !force
         # ActiveSupport::Notifications.publish BeforeLoadEvent, self # before_load hook
         # puts files.inspect
         files.each{ |file| load file }                             # load files
         # ActiveSupport::Notifications.publish AfterLoadEvent, self  # after_load hook
         @@loaded = true
       end
     end

     def load(file)
       Rails.logger.debug "ActionBlocks::Loader load(#{file})"
       DatabaseHitDuringLoad.capture{ super }
     end

     # Returns ALL the files to be loaded
     def files
       load_paths.flatten.compact.uniq.flat_map{ |path| Dir["#{path}/**/*.rb"] }
     end

    # Since app/blocks is alphabetically before app/models, we have to remove it
    # from the host app's +autoload_paths+ to prevent missing constant errors.
    #
    # As well, we have to remove it from +eager_load_paths+ to prevent the
    # files from being loaded twice in production.
    def remove_active_admin_load_paths_from_rails_autoload_and_eager_load
      ActiveSupport::Dependencies.autoload_paths -= load_paths
      Rails.application.config.eager_load_paths  -= load_paths
    end

    # Hook into the Rails code reloading mechanism so that things are reloaded
    # properly in development mode.
    #
    # If any of the app files (e.g. models) has changed, we need to reload all
    # the admin files. If the admin files themselves has changed, we need to
    # regenerate the routes as well.
    def attach_reloader
      # ActiveSupport::Reloader.to_prepare(*args, &block)
      Rails.application.config.after_initialize do |app|
          if app.config.reload_classes_only_on_change
            # Rails is about to unload all the app files (e.g. models), so we
            # should first unload the classes generated by Active Admin, otherwise
            # they will contain references to the stale (unloaded) classes.
            ActiveSupport::Reloader.to_prepare(prepend: true) do
              ActionBlocks.unload!
            end
          else
            # If the user has configured the app to always reload app files after
            # each request, so we should unload the generated classes too.
            ActiveSupport::Reloader.to_complete() do
              puts "ActiveSupport::Reloader.to_complete()\n"
              # ActionBlocks.application.unload!
              # @@loaded = false
            end
          end

          # block_drs = {}
          #
          # load_paths.each do |path|
          #   block_drs[path] = [:rb]
          # end

          # routes_reloader = app.config.file_watcher.new([], block_drs) do
          #   app.reload_routes!
          # end
          #
          # app.reloaders << routes_reloader

          ActiveSupport::Reloader.to_prepare do
            # Rails.logger.debug("--> 1. ActionBlocks::Loader.new('app/blocks')")
            loader = ActionBlocks::Loader.new('app/blocks')
            loader.unload!
            loader.load!
            ActionBlocks.after_load

            # loader.attach_reloader
            # Rails might have reloaded the routes for other reasons (e.g.
            # routes.rb has changed), in which case Active Admin would have been
            # loaded via the `ActiveAdmin.routes` call in `routes.rb`.
            #
            # Otherwise, we should check if any of the admin files are changed
            # and force the routes to reload if necessary. This would again causes
            # Active Admin to load via `ActiveAdmin.routes`.
            #
            # Finally, if Active Admin is still not loaded at this point, then we
            # would need to load it manually.
            # unless ActionBlocks.application.loaded?
              # routes_reloader.execute_if_updated
              # self.load!
            # end
          end
        end
    end #attach_reloader
  end
end
