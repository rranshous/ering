require 'rspec'
require_relative '../lib/node'

describe EventRing::Node do

  it "includes AASM" do
    expect(subject).to respond_to(:aasm)
  end

  describe "#join_ring" do
    it "responds to ring events" do
      expect(subject).to receive(:test_event).with({ test: 1 })
      ring = EventRing::Ring.new
      subject.join_ring ring
      ring.publish :test_event, test: 1
    end
  end

  it "has default id" do
    ids = ([0]*10).map{ described_class.new.id }
    expect(ids.uniq.length).to eq 10
  end

  it "reflects the class name as it's type" do
    class T1 < EventRing::Node
    end
    expect(T1.new.type).to eq "T1"
  end

end
