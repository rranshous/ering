class Battle < EventRing::Node
  aasm do
    state :uninitialized, initial: true
    state :initializing, before_enter: :do_initializing,
                         after_enter: :publish_initializing
    state :initialized, after_enter: :publish_initialized
    state :starting
    state :starting_round, after_enter: :start_round
    state :finishing_round, after_enter: :finish_round
    state :round_finished, after_enter: :publish_round_finished

    event :game_initializing do
      transitions from: :uninitialized, to: :initializing
    end

    event :game_starting do
      transitions from: :initialized, to: :starting
    end

    event :base_initialized do
      transitions from: :initializing, to: :initialized do
        guard do |data|
          @base_checkins += 1
          @base_checkins == @bases.length
        end
      end
    end

    event :round_starting do
      transitions to: :starting_round
    end

    event :round_end do
      transitions to: :ending_round
    end
  end

  def initialize state_collector
    @state_collector = state_collector
    @base_checkins = 0
    @round = 0
    super()
  end

  private

  def do_initializing
    set_base_locations
  end

  def start_round
    publish :round_start, { round_num: @round }
  end

  def finish_round
  end

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
end

