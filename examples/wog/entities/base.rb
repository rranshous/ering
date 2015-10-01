class Base < EventRing::Node
  aasm do
    state :uninitialized, initial: true
    state :initialized, after_enter: :publish_initialized

    event :base_location_set do
      transitions from: :uninitialized, to: :initialized do
        guard do |data|
          data[:base_id] == id
        end
        after do |data|
          @location = [data[:x], data[:y]]
        end
      end
    end
  end

  def publish_initialized
    publish :base_initialized, { base_id: id, location: @location }
  end
end

