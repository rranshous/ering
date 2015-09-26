require 'rspec'
require_relative '../lib/ring_set'
require_relative '../lib/ring'
require_relative '../lib/node'

describe EventRing::RingSet do

  let(:ring1) { EventRing::Ring.new }
  let(:ring2) { EventRing::Ring.new }
  let(:node1) { EventRing::Node.new }
  let(:node2) { EventRing::Node.new }

  describe EventRing::RingSet::Relay do
    context "two rings attached" do
      it "passes events from source ring to target ring" do
        node1.join_ring ring1
        node2.join_ring ring2
        expect(node1).to receive(:cascading_event).once
        expect(node2).to receive(:cascading_event).once
        expect(node2).to receive(:isolated_event).once
        described_class.new(ring1, ring2)
        ring1.publish :cascading_event
        ring2.publish :isolated_event
      end

      context "with filter" do
        it "uses provided block to filter messages" do
          node1.join_ring ring1
          node2.join_ring ring2
          expect(node1).to receive(:for_all).once
          expect(node2).to receive(:for_all).once
          expect(node1).to receive(:for_us).once
          expect(node2).to receive(:for_us).never
          described_class.prepend(EventRing::RingSet::Filter)
            .new(ring1, ring2){ |e, d| e == :for_all }
          ring1.publish :for_all
          ring1.publish :for_us
        end
      end
    end
  end

  describe EventRing::RingSet::Peer do
    context "two rings attached as peers" do
      it "one ring's published events are received by the other ring's nodes" do
        node1.join_ring ring1
        node2.join_ring ring2
        expect(node1).to receive(:testevent).with({ success: 1 }).once
        expect(node2).to receive(:testevent).with({ success: 1 }).once
        expect(node1).to receive(:testevent).with({ success: 2 }).once
        expect(node2).to receive(:testevent).with({ success: 2 }).once
        described_class.new(ring1, ring2)
        ring1.publish :testevent, { success: 1 }
        ring2.publish :testevent, { success: 2 }
      end
    end
  end

  describe EventRing::RingSet::Sub do
    context "one ring is a sub ring" do
      it "passes messages from parent to the sub ring with filter" do
        node1.join_ring ring1
        node2.join_ring ring2
        expect(node1).to receive(:for_all).with({ success: 1 }).once
        expect(node2).to receive(:for_all).with({ success: 1 }).once
        expect(node1).to receive(:for_us).with({ success: 2 }).once
        expect(node2).to receive(:for_us).with({ success: 2 }).never
        described_class.new(ring1, ring2) do |event, data|
          event == :for_all
        end
        ring1.publish :for_all, { success: 1 }
        ring1.publish :for_us, { success: 2 }
      end

      it "passes all messages from sub ring to parent" do
        node1.join_ring ring1
        node2.join_ring ring2
        expect(node1).to receive(:for_all).once
        expect(node2).to receive(:for_all).once
        expect(node1).to receive(:for_us).once
        expect(node2).to receive(:for_us).never
        described_class.new(ring1, ring2) do |event, data|
          false # pass none to sub ring
        end
        ring2.publish :for_all
        ring1.publish :for_us
      end
    end
  end
end
