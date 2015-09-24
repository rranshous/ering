
# combines several rings such that some rings
# receive a subset of hte information of other rings

module EventRing
  module RingSet
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

    class Peer
      def initialize *rings
        @rings = rings
        @observers = []
        initialize_observers
        @in_flight = Hash.new({})
      end

      def receiver publishing_ring, *args
        @rings.each do |ring|
          next if publishing_ring == ring
          next if @in_flight[ring].delete(args)
          @in_flight[ring][args] = 1
          ring.publish(*args)
        end
      end

      private

      def initialize_observers
        @observers = @rings.map do |ring|
          CallIdentifier.new(self, :receiver, ring).tap{ |obs| ring.join obs }
        end
      end
    end
  end
end
