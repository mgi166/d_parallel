require 'drb/drb'
require 'rinda/tuplespace'
require 'tapp'

#=TEST
# pry -r './lib/d_parallel'
# d = DParallel.new([1,2,3], 1); d.map{|i| i * 2}
#
class DParallel
  attr_accessor :enum, :tuple
  def initialize(enum, num)
    @enum  = enum
    @tuple = Rinda::TupleSpace.new(600)
    start_service
  end

  def each
    return @enum unless block_given?
  end

  def map(&block)
    p uri
    @enum.each do |e|
      @tuple.write([:pre_call, e, block])
    end

    [].tap do |result|
      result << @tuple.take([:after_call, nil, nil])
    end
  end

  def start_service
    DRb.start_service(nil, @tuple)
  end

  def uri
    DRb.uri
  end

  def call
    label, e, block = @tuple.take [:pre_call, nil, Proc]
    called = block.call(e)
    @tuple.write [:after_call, e, called]
  end
end
