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

    @enum.each do |e|
    end
  end

  def start_service
    DRb::DRbObject.start_service(nil, @tuple)
  end

  def uri
    DRb.uri
  end
end
