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
    pid = fork do
      proxy = Rinda::TupleSpaceProxy.new(DRbObject.new(@tuple))
      start_service
      @enum.each do |e|
        proxy.write [:after, e, block.call(e)] rescue nil
      end
    end

    @enum.map do |e|
      _, _, result = @tuple.read [:after, e, nil]
      result
    end
  end

  def start_service
    DRb.stop_service
    DRb.start_service(nil, @tuple)
  end

  def uri
    DRb.uri
  end
end
