require 'spec_helper'

describe DParallel do
  describe '#new' do
    describe 'if arguments are valid' do
      subject { described_class.new(enum, num) }

      let(:enum) { [1,2,3] }
      let(:num)  { 3 }

      it { should be_instance_of DParallel }
    end
  end
end
