# -*- coding: utf-8 -*-
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
    @num   = num
    @tuple = Rinda::TupleSpace.new(180)
  end

  def map(&block)
    start_service

    client = Client.new(@tuple, @num)

    @enum.map do |e|
      @tuple.write [:pre_call, e, block]
      client.call_block
      result = @tuple.take([:after_call, e, nil], 3)
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
    def initialize(tuple, num)
      @num   = num
      @tuple = DRbObject.new(tuple)
    end

    def call_block
      _fork do
        _call
      end
    end

    private

    def _call
      DRb.start_service

      _, e, block = @tuple.take([:pre_call, nil, Proc])
      called = block.call(e)
      @tuple.write [:after_call, e, called] rescue nil
    end

    def _fork(&block)
      @num.times do
        Process.fork do
          yield
        end
      end
    end
  end
end
