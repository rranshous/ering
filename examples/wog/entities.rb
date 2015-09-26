require_relative '../../lib/ering'

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

class Warrior < EventRing::Node
  aasm do
    state :uninitialized
    state :alive
  end
end

class Scoreboard < EventRing::Node
  aasm do
    state :on

    event :game_starting do
      after { puts "game starting" }
    end
  end
end

class Battle < EventRing::Node
  aasm do
    state :uninitialized, initial: true
    state :initializing, after_enter: :publish_initializing
    state :initialized, after_enter: :publish_initialized
    state :started, after_enter: :publish_started

    event :game_initializing do
      transitions from: :uninitialized, to: :initializing
    end

    event :base_initialized do
      transitions from: :initializing, to: :initialized do
        guard do |data|
          @base_checkins += 1
          @base_checkins == @bases.length
        end
      end
    end
  end

  def initialize state_collector
    @state_collector = state_collector
    @base_checkins = 0
    super()
  end

  def start_game
    self.game_initializing
    set_base_locations
    #self.initialized
    #self.starting
    #self.started
  end

  private

  def set_base_locations
    @bases = @state_collector.state["Base"].keys
    @bases.each_with_index do |base_id, i|
      publish :base_location_set, {
        x: i, y: i,
        base_id: base_id
      }
    end
  end

  def publish_initializing
    publish :battle_initializing
  end

  def publish_initialized
    publish :battle_initialized
  end

  def publish_started
    publish :battle_started
  end
end

