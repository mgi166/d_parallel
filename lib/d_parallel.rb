require 'drb/drb'
require 'rinda/tuplespace'

# require './lib/d_parallel'
class DParallel
  attr_accessor :enum, :tuple
  def initialize(enum, num)
    @enum  = enum
    @tuple = Rinda::TupleSpace.new
  end

  def each
    return @enum unless block_given?
  end

  def map
    @enum.each do |e|
      @tuple.write [:pre_call, e, block]
    end

    [].tap do |result|
    end
  end

  def start_service
    DRb::DRbObject.start_service(nil, @tuple)
  end

  def uri
    DRb.uri
  end

  def call
    label, e, block = @tuple.take [:pre_call, e, block]
    called = block.call(e)
    @tuple.write [:after_call, e, called]
  end
end
