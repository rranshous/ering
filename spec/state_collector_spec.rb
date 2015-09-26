require 'rspec'
require_relative '../lib/state_collector'

describe EventRing::StateCollector do
    let(:ring1) { double(state: { car: { "1": {} } }) }
    let(:ring2) { double(state: { car: { "2": {} } }) }
  subject { described_class.new ring1, ring2 }
  it "merges the ring's states" do
    expect(subject.state).to eq({
      car: {
        "1": {},
        "2": {}
      }
    })
  end
end
