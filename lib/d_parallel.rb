require 'drb/drb'
require 'rinda/tuplespace'

class DParallel
  attr_accessor :enum, :tuple
  def initialize(enum, num)
    @enum  = enum
    @tuple = Rinda::TupleSpace.new
  end

  def each
    return @enum unless block_given?
  end

  def start_service
    DRb::DRbObject.start_service(nil, @tuple)
  end
end
