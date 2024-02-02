# frozen_string_literal: true

# Adds support for default and action_missing rendering of Phlex views. So instead of this:
#
#   class UsersController
#     def index
#       render Views::Users::Index.new
#     end
#
#     def show
#       render Views::Users::Show.new(user)
#     end
#   end
#
# You can do this:
#
#   class UsersController
#     include Phlexible::Rails::ActionController::ImplicitRender
#   end
#
module Phlexible
  module Rails
    module ActionController
      module ImplicitRender
        def default_render
          render_plex_view({ action: action_name }) || super
        end

        def method_for_action(action_name)
          super || ('default_phlex_render' if phlex_view(action_name))
        end

        def default_phlex_render
          render phlex_view(action_name).new
        end

        # @param options [Hash] At a minimum this may contain an `:action` key, which will be used
        #   as the name of the view to render. If no `:action` key is provided, the current
        #   `action_name` is used.
        def render_plex_view(options)
          options[:action] ||= action_name

          return unless (view = phlex_view(options[:action]))

          render view.new, options
        end

        private

        def phlex_view(action_name = @_action_name)
          phlex_view_path(action_name).classify.safe_constantize
        end

        def phlex_view_path(action_name)
          "#{controller_path}/#{action_name}_view"
        end
      end
    end
  end
end
