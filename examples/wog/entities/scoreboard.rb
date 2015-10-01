class Scoreboard < EventRing::Node
  aasm do
    state :on

    event :game_starting do
      after { puts "game starting" }
    end
  end
end

