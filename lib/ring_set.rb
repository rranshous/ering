
# combines several rings such that some rings
# receive a subset of hte information of other rings

module EventRing
  module RingSet

    class Peer
      def initialize ring1, ring2
        @in_flight = Hash.new({})
        Relay.prepend(Filter).new(ring1, ring2, &filter_for(ring1, ring2))
        Relay.prepend(Filter).new(ring1, ring2, &filter_for(ring2, ring1))
      end

      private

      # not very sophisticated
      def filter_for source_ring, target_ring
        in_flight = @in_flight
        lambda do |event, data|
          if in_flight[target_ring].delete([event, data])
            false
          else
            in_flight[source_ring][[event, data]] = :IN_FLIGHT
            true
          end
        end
      end
    end

    class Sub
      def initialize parent_ring, sub_ring, &allow_to_sub_ring
        Relay.prepend(Filter).new(parent_ring, sub_ring) do |event, data|
          allow_to_sub_ring.call event, data
        end
      end
    end

    class Relay
      def initialize source_ring, target_ring
        @source_ring, @target_ring = source_ring, target_ring
        @observer = CallIdentifier.new(self, :call_received, @source_ring)
        @source_ring.join @observer
      end

      def call_received publishing_ring, event, data
        @target_ring.publish event, data
      end
    end

    module Filter
      def initialize source_ring, target_ring, &passes_filter
        @passes_filter = passes_filter
        super source_ring, target_ring
      end

      def call_received publishing_ring, event, data
        super if @passes_filter.call event, data
      end
    end

    class CallIdentifier
      def initialize target, method, id
        @target = target
        @method = method
        @id = id
      end

      def method_missing *args
        @target.send @method, @id, *args
      end
    end
  end
end
