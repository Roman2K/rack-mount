module Rack
  module Mount
    class RouteSet
      def draw(&block)
        Mappers::RailsClassic.new(self).draw(&block)
        freeze
      end
    end

    module Mappers
      class RailsClassic
        DynamicController = lambda { |env|
          app = "#{env["rack.routing_args"][:controller].camelize}Controller"
          app = ActiveSupport::Inflector.constantize(app)
          app.call(env)
        }

        attr_reader :named_routes

        def initialize(set)
          @set = set
          @named_routes = {}
        end

        def draw(&block)
          require 'action_controller'
          yield ActionController::Routing::RouteSet::Mapper.new(self)
        end

        def add_route(path, options = {})
          path = path.gsub(".:format", "(.:format)")

          if conditions = options.delete(:conditions)
            method = conditions.delete(:method)
          end

          name = options.delete(:name)

          requirements = options.delete(:requirements) || {}
          defaults = {}
          options.each do |k, v|
            if v.is_a?(Regexp)
              requirements[k.to_sym] = options.delete(k)
            else
              defaults[k.to_sym] = options.delete(k)
            end
          end

          app = defaults.has_key?(:controller) ?
            ActiveSupport::Inflector.constantize("#{defaults[:controller].camelize}Controller") :
            DynamicController

          @set.add_route(app, {
            :name => name,
            :path => path,
            :method => method,
            :requirements => requirements,
            :defaults => defaults
          })
        end

        def add_named_route(name, path, options = {})
          options[:name] = name
          add_route(path, options)
        end
      end
    end
  end
end
