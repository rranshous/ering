module EventRing
  class Ring
    def initialize
      @members = []
    end

    def join node
      @members << node
    end

    def publish event, data={}, sender=nil
      @members
        .reject{ |n| n == sender }
        .each{ |n| puts "N: #{n}; e: #{event}; d: #{data}"; n.send(event, data) }
    end

    def state
      {}.tap do |r|
        @members.each do |node|
          if node.respond_to? :state
            (r[node.type] ||= {})[node.id] = node.state
          end
        end
      end
    end
  end
end

