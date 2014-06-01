# -*- coding: utf-8 -*-
require 'drb/drb'
require 'rinda/tuplespace'
require 'tapp'

#=TEST
# pry -r './lib/d_parallel'
# d = DParallel.new([1,2,3], 1); d.map{|i| i * 2}
# d = DParallel.new([1,2,3], 1); [].tap {|x| d.each{|i| x << (i * 2)} }
#
class DParallel
  attr_accessor :enum, :tuple
  def initialize(enum, num)
    @enum  = enum
    @num   = num
    @tuple = Rinda::TupleSpace.new(180)
  end

  def each(&block)
    enum = Enumerator.new do |yielder|
      @enum.each do |i|
        yielder.yield yield(i)
      end
    end

    enum.each(&block)
  end

  def map(&block)
    start_service

    pids = create_process(&block)
    collect_result(pids)
  end

  private

  def collect_result(pid)
    @enum.map do |e|
      _, _, result = @tuple.read [:after, e, nil]
      result
    end.tap do
      pid.each {|id| Process.waitpid(id) }
    end
  end

  def create_process(&block)
    raise 'The number of fork process is over than 0' if @num.to_i.zero?

    Array.new(@num) do
      fork_process(@d_obj, &block)
    end
  end

  def fork_process(d_obj, &block)
    Process.fork do
      start_service
      proxy = Rinda::TupleSpaceProxy.new(d_obj)
      @enum.each do |e|
        proxy.write [:after, e, block.call(e)] rescue nil
      end
    end
  end

  def start_service
    DRb.stop_service
    DRb.start_service(nil, @tuple)
    @d_obj = DRbObject.new(@tuple)
  end
end
