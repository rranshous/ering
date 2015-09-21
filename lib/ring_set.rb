
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
        puts "MM"
        @target.send @method, @id, *args
      end
    end

    class Peer
      def initialize *rings
        @rings = rings
        @rings.each do |ring|
          obs = CallIdentifier.new self, :receiver, ring
          ring.join obs
        end
      end

      def receiver publishing_ring, *args
        @rings.each do |ring|
          ring.publish(*args)
        end
      end
    end
  end
end
