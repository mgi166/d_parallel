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
  end

  def each
    return @enum unless block_given?
  end

  def map(&block)
    start_service

    client = Client.new(uri)

    @enum.map do |e|
      @tuple.write [:pre_call, e, block]
      client.call_block
      result = @tuple.take [:after_call, e, nil]
      result.last
    end
  end

  def start_service
    DRb.stop_service
    DRb.start_service(nil, @tuple)
  end

  def uri
    DRb.uri
  end

  class Client
    def initialize(uri)
      DRb.start_service
      @tuple = DRbObject.new_with_uri(uri)
    end

    def call_block
      _, e, block = @tuple.take [:pre_call, nil, Proc]
      called = block.call(e)
      @tuple.write [:after_call, e, called]
    end
  end
end
