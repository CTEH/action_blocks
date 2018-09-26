module ActionBlocks

  class WorkspaceBuilder < ActionBlocks::BlockType
    block_type :workspace
    sets :title
    builds_many :subspaces, :subspace, 'ActionBlocks::SubspaceBuilder'
    # builds_many :record_paths, :record_path, 'ActionBlocks::RecordPathBuilder'

    validate :one_route_per_model
    validate :one_non_model_subspace_per_category

    def one_non_model_subspace_per_category
      subspace_categories.each do |sc|
        if @subspaces.
          select {|ss| ss.category == sc && ss.model_key.nil? }.count > 1
          errors.add(:subspaces, "Subspace category #{sc.to_s} has more than one non-modeled subspace")
        end
      end
    end

    def one_route_per_model
      models = subspaces.map {|ss| ss.model_key}.compact
      subspaces.each do |ss|
        models += ss.dashboards.map {|ss| ss.model_key}.compact
      end
      models.uniq.each do |model|
        if models.select {|m| model == m}.count > 1
          errors.add(:subspaces, "More than one subspace or dashboard uses model #{model}")
        end
      end
    end

    def before_build(parent, *args)
      @title = args[0].to_s.titleize
    end

    def subspace_categories
      @subspaces.map(&:category).uniq
    end

    def model_paths
      subspace_paths.merge(dashboard_paths)
    end

    def subspace_paths
      paths = {}
      @subspaces.each do |ss|
        if ss.model_key
          paths[ss.model_key] = {
            path_type: :subspace,
            subspace_category: ss.category,
            subspace_model: ss.model_key,
            subspace_key: ss.key
          }
        end
      end
      return paths
    end

    def dashboard_paths
      paths = {}
      @subspaces.each do |ss|
        if ss.model_key
          ss.dashboards.each do |ds|
            paths[ds.model_key] = {
              path_type: :dashboard,
              subspace_category: ss.category,
              subspace_model: ss.model_key,
              subspace_key: ss.key,
              dashboard_category: ds.category,
              dashboard_model: ds.model_key,
              dashboard_key: ds.key
            }
          end
        end
      end
      return paths
    end

    def hashify_subspace_categories(user)
      isFirst = true
      results = []
      subspace_categories.each do |category|
        results << {
          first: isFirst,
          type: 'subspace_category',
          category: category,
          title: category.to_s.titleize,
          subspaces: @subspaces.
            select {|ss| ss.category == category}.
            map { |ss| ss.hashify(user) },
        }
        isFirst = false
      end
      return results
    end

    def hashify(user)
      {
        # key: key,
        title: @title,
        id: @id,
        subspaces: @subspaces.map { |ss| ss.hashify(user) },
        subspace_categories: hashify_subspace_categories(user),
        model_paths: model_paths
        # record_paths: @record_paths.map { |rp| rp.hashify(user) }
      }
    end
  end

  # class RecordPathBuilder < ActionBlocks::BaseBuilder
  #   sets :model # currently used by table to find this
  #
  #   sets :subspace # What path/url to share to control active navigation
  #   sets :recordspace # What recordspace to render
  #   sets :dashboard # What path/url of the recordspace dashboard to control active navigation
  #   sets :recordboard # What recordboard to render
  #
  #   def before_build(parent, *args)
  #     # When Creating Links for Records of type @model
  #     @model = args[0]
  #     # Create Links with this information
  #     @subspace = args[1]
  #     @recordspace = args[2]
  #     @dashboard = args[3]
  #     @recordboard = args[4]
  #   end
  #
  #   def hashify(user)
  #     {
  #       model: @model,
  #       subspace: @subspace,
  #       dashboard: @dashboard,
  #       recordspace: @recordspace,
  #       recordboard: @recordboard
  #     }
  #   end
  # end

  class SubspaceBuilder < ActionBlocks::BaseBuilder
    attr_accessor :workspace
    sets :title
    sets :category
    references :model
    builds_many :dashboards, :dashboard, 'ActionBlocks::DashboardBuilder'
    sets_many :recordspace_keys, :mounts

    validates :category, presence: true

    def key
      "subspace-#{@id}".to_sym
    end

    def before_build(parent, *args)
      @workspace = parent
      @title = args[0].to_s.titleize
      @category = args[0]
      if args[1]
        @model_key = "model-#{args[1]}"
      end
    end

    def dashboard_categories
      @dashboards.map(&:category).uniq
    end

    def hashify_dashboard_categories(user)
      isFirst = true
      results = []
      dashboard_categories.each do |category|
        results << {
          first: isFirst,
          type: 'dashboard_categories',
          category: category,
          title: category.to_s.titleize,
          dashboards: @dashboards.
            select {|d| d.category == category}.
            map { |d| d.hashify(user) },
        }
        isFirst = false
      end
      return results
    end


    def hashify(user)
      {
        key: key,
        title: @title,
        category: @category,
        model: @model_key,
        dashboards: @dashboards.map{ |db| db.hashify(user) },
        dashboard_categories: hashify_dashboard_categories(user),
        recordspace_keys: @recordspace_keys
      }
    end
  end

  class DashboardBuilder < ActionBlocks::BaseBuilder
    attr_accessor :workspace, :subspace
    sets :title
    sets :category
    references :model
    builds_many :dashlets, :table, 'ActionBlocks::TableBuilder'
    builds_many :dashlets, :barchart, 'ActionBlocks::BarchartBuilder'
    builds_many :dashlets, :mount_form, 'ActionBlocks::MountedFormBuilder'

    def before_build(parent, *args)
      @subspace = parent
      @workspace = @subspace.workspace
      @category = args[0]
      @title = @category.to_s.titleize
      if args[1]
        @model_key = "model-#{args[1]}"
      end
    end

    validates :category, presence: true
    validate :has_unique_dashlets
    def has_unique_dashlets
      @dashlets.group_by(&:key).each do |k, dashlets|
          if(dashlets.length > 1)
            d = dashlets.first
            errors.add(:dashlets, "Duplicate #{d.type.inspect} added to dashboard #{workspace.id}/#{subspace.id}/#{id} with id #{d.id.inspect}")
          end
      end
    end

    def hashify(user)
      {
        key: key,
        title: @title,
        model: @model_key,
        category: @category,
        dashlet_keys: @dashlets.map(&:key)
      }
    end
  end

  class MountedFormBuilder < ActionBlocks::BlockType
    block_type :mounted_form
    references :form

    def before_build(parent, *args)
      @id = args[0]
      @dashboard = parent
      @subspace = @dashboard.subspace
      @form_key = "form-#{@id}"
    end

    # validate :validate_mounted_to
    # def validate_mounted_to
    #   return unless [:dashboard, :subspace].include?(@mounted_to)
    #   errors.add(:mounted_to, "#{@parent.key} #{type} must be mounted to :dashboard or :subspace but #{@mounted_to.inspect} was specified.")
    # end
    #
    # validate :validate_mount_point_matches_model
    # def validate_mount_point_matches_model
    #   # TODO
    # end

    def after_load
      # After load is called after all blocks are in the store
      if form.model.id == @subspace.model.try(:id)
        @mounted_to = :subspace
      end
      if form.model.id == @dashboard.model.try(:id)
        @mounted_to = :dashboard
      end
    end

    def hashify(user)
      {
        type: :mounted_form,
        form_key: @form_key,
        mounted_to: @mounted_to
      }
    end
  end


end
