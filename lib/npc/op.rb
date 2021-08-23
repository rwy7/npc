# typed: strict
# frozen_string_literal: true

module NPC
  # A base class for implementing operation.
  class Op < InBlock
    include Base
    include Operation

    sig do
      params(
        location: Location,
        operands: T::Array[Operand],
        results: T::Array[Result],
      ).void
    end
    def initialize(
      location:,
      operands:,
      results:
    )
      @location = T.let(location, Location)
      @operands = T.let(operands, T::Array[Operand])
      @results  = T.let(results,  T::Array[Result])
    end

    sig { override.returns(Location) }
    attr_reader :location

    sig { override.returns(T::Array[Operand]) }
    attr_reader :operands

    sig { override.returns(T::Array[Result]) }
    attr_reader :results
  end
end
