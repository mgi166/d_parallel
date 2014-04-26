require 'rinda/tuplespace'
require 'drb/drb'

class DParallel
  def initialize(enum, num)
    @enum = enum
    @num  = num
  end
end
