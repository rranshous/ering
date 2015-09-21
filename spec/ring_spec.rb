require 'rspec'
require_relative '../lib/ring'

describe EventRing::Ring do
  let(:node) { double('node',
                      id: '1234', type: 'testtype', state: { 'success' => 1 }) }
  let(:node2) { double('node',
                       id: '4321', type: 'testtype', state: { 'success' => 2 }) }

  it "publishes events to all members" do
    subject.join node
    expect(node).to receive(:test).with({success: 1})
    subject.publish :test, success: 1
  end

  it "does not publish back to sender" do
    subject.join node
    expect(node).not_to receive(:test)
    subject.publish :test, {success: 1}, node
  end

  it "collects up ring state" do
    subject.join node
    subject.join node2
    expect(subject.state).to eq({
      'testtype' => {
        '1234' => { 'success' => 1 },
        '4321' => { 'success' => 2 }
      }
    })
  end

  it "doesn't collect state if obj doesn't give it" do
    subject.join node
    subject.join double('faker')
    expect(subject.state).to eq({
      'testtype' => {
        '1234' => { 'success' => 1 }
      }
    })
  end
end
