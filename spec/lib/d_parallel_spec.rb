require 'spec_helper'

describe DParallel do
  describe '#new' do
    describe 'if arguments are valid' do
      subject { described_class.new([1,2,3], 3) }

      it { should be_instance_of DParallel }
    end
  end

  describe '#map' do
    describe 'when square elements in block' do
      subject { d_parallel.map{|x| x*2 } }
      let(:d_parallel) { described_class.new([1,2,3], 3) }

      it { should be_instance_of Array }

      it 'elements should be square' do
        should == [2, 4, 6]
      end
    end

    describe 'when enum object is large' do
      subject { d_parallel.map{|x| x } }
      let(:d_parallel) { described_class.new((1..100).to_a, 2) }

      it { should be_instance_of Array }

      it 'elements should be square' do
        should == (1..100).to_a
      end
    end
  end

  describe '#create_process' do
    subject { d_parallel.send(:create_process) {|x| x} }
    let(:d_parallel) { described_class.new([1,2,3], 3) }

    it 'should return Array' do
      d_parallel.stub(:fork_process)
      should be_instance_of Array
    end

    it 'should call #fork_process @num times' do
      d_parallel.should_receive(:fork_process).exactly(3)
      subject
    end
  end
end
