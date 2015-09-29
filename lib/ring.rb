module EventRing
  class Ring
    def initialize
      @members = []
      @to_publish = []
    end

    def join node
      @members << node
    end

    def publish event, data={}, sender=nil
      @to_publish << [event, data, sender]
      if @to_publish.length == 1
        begin
          e, d, s = @to_publish.first
          @members.reject{ |n| n == s }.each{ |n| n.send(e, d.dup) }
          @to_publish.shift
        end until @to_publish.length == 0
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

