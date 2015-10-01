class Warrior < EventRing::Node
  aasm do
    state :uninitialized
    state :alive
  end
end

