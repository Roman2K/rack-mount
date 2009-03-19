module Rack
  module Mount
    class RouteSet
      DEFAULT_OPTIONS = {
        :optimize => false,
        :keys => [:method, :first_segment]
      }.freeze

      def initialize(options = {})
        @options = DEFAULT_OPTIONS.dup.merge!(options)
        @keys = @options.delete(:keys)
        @named_routes = {}
        @root = NestedSet.new

        if @options[:optimize]
          extend Optimizations::RouteSet
        end

        if block_given?
          yield self
          freeze
        end
      end

      def add_route(app, options = {})
        route = Route.new(app, options)
        keys = @keys.map { |key| route.send(key) }
        @root[*keys] = route
        @named_routes[route.name] = route if route.name
        route
      end

      def url_for(named_route, options = {})
        @named_routes[named_route.to_sym].url_for(options)
      end

      def call(env)
        raise "route set not finalized" unless frozen?

        keys = keys_for(env)
        @root[*keys].each do |route|
          result = route.call(env)
          return result unless result[0] == 404
        end
        nil
      end

      def freeze
        @root.freeze
        super
      end

      def deepest_node
        @root.deepest_node
      end

      def height
        @root.height
      end

      def to_graph
        @root.to_graph
      end

      private
        def keys_for(env)
          req = Request.new(env)
          @keys.map { |key| req.send(key) }
        end
    end
  end
end
