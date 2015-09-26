require 'deep_merge'
module EventRing
  class StateCollector
    def initialize *rings
      @rings = rings
    end

    def state
      {}.tap do |r|
        @rings.each do |ring|
          r.deep_merge!(ring.state)
        end
      end
    end
  end
end
