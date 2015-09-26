module EventRing
  class Ring
    def initialize
      @members = []
    end

    def join node
      @members << node
    end

    def publish event, data={}, sender=nil
      puts "#{object_id} publishing: #{event} :: #{data}"
      @members
        .reject{ |n| n == sender }
        .each do |n|
          n.send(event, data.dup)
        end
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

