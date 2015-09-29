require 'rspec'
require_relative '../lib/ring'

describe EventRing::Ring do
  let(:node) { double('node',
                      id: '1234', type: 'testtype', state: { 'success' => 1 }) }
  let(:node2) { double('node',
                       id: '4321', type: 'testtype', state: { 'success' => 2 }) }
  let(:editing_node) do
    o = Object.new
    def o.testevent data
      data[:success] = 2
    end
    o
  end

  it "publishes events to all members" do
    subject.join node
    expect(node).to receive(:testevent).with({success: 1})
    subject.publish :testevent, success: 1
  end

  it "does not publish back to sender" do
    subject.join node
    expect(node).not_to receive(:testevent)
    subject.publish :testevent, {success: 1}, node
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

  it "does not allow a node to change the data it sends to other nodes" do
    subject.join editing_node
    subject.join node
    expect(node).to receive(:testevent).with({success: 1})
    subject.publish :testevent, { success: 1 }
  end

  it 'defers next publish until current fanout is complete' do
    publishing_node = Object.new
    def publishing_node.testevent data
      puts "adding"
      @ring.publish :secondevent, {}, self
    end
    publishing_node.instance_variable_set(:@ring, subject)
    subject.join publishing_node
    subject.join node
    expect(publishing_node).to receive(:testevent).and_call_original.ordered
    expect(node).to receive(:testevent).and_return(nil).ordered
    expect(node).to receive(:secondevent).and_return(nil).ordered
    subject.publish :testevent
  end
end
