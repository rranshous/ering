require 'aasm'

module EventRing
  class Node

    include AASM

    aasm(:whiny_transitions => false) {}

    def receive event, data
      self.send event, nil, data
    end

    def state
      Hash[self.class.aasm.states.map{ |s| [s.name, send("#{s.name}?")] }]
    end

    def publish event, data={}
      @ring.publish event, data, self
    end

    def join_ring ring
      @ring = ring
      @ring.join self
    end

    def id
      @id ||= SecureRandom.uuid
    end

    def type
      self.class.name.split('::').last
    end

    def method_missing *args
      # swallow things
    end
  end
end
