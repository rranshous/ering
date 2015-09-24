require 'rspec'
require_relative '../lib/ring_set'
require_relative '../lib/ring'
require_relative '../lib/node'

describe EventRing::RingSet do

  let(:ring1) { EventRing::Ring.new }
  let(:ring2) { EventRing::Ring.new }
  let(:node1) { EventRing::Node.new }
  let(:node2) { EventRing::Node.new }

  describe EventRing::RingSet::Peer do
    context "two rings attached as peers" do
      it "one ring's published events are received by the other ring's nodes" do
        node1.join_ring ring1
        node2.join_ring ring2
        expect(node1).to receive(:testevent).with({ success: 1 }).once
        expect(node2).to receive(:testevent).with({ success: 1 }).once
        described_class.new(ring1, ring2)
        ring1.publish :testevent, { success: 1 }
      end
    end
  end
end
