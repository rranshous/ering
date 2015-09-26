# simple game
# two bases
# warriors come from bases
# warriors kill other warriors
# warriors kill bases

require_relative 'entities'
require_relative '../../lib/ering'

world_ring = EventRing::Ring.new
player1_ring = EventRing::Ring.new
player2_ring = EventRing::Ring.new

state_collector = EventRing::StateCollector.new(world_ring,
                                                 player1_ring, player2_ring)

battle = Battle.new state_collector
scoreboard = Scoreboard.new

battle.join_ring world_ring
scoreboard.join_ring world_ring

player1_base = Base.new
player2_base = Base.new

player1_warrior = Warrior.new
player2_warrior = Warrior.new

player1_base.join_ring player1_ring
player2_base.join_ring player2_ring

player1_warrior.join_ring player1_ring
player2_warrior.join_ring player2_ring

EventRing::RingSet::Sub.new(world_ring, player1_ring) do |event, data|
  true # allow all throught for now
end
EventRing::RingSet::Sub.new(world_ring, player2_ring) do |event, data|
  true # allow all throught for now
end

battle.start_game
