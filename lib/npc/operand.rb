# typed: strict
# frozen_string_literal: true

module NPC
  # An input to an operation, and a reference to a value.
  class Operand
    extend T::Sig
    extend T::Helpers

    sig do
      params(
        parent_operation: T.nilable(Operation),
        target:           T.nilable(Value),
      ).void
    end
    def initialize(parent_operation = nil, target = nil)
      @parent_operation = T.let(parent_operation, T.nilable(Operation))
      @target = T.let(nil, T.nilable(Value))
      @prev_use = T.let(nil, T.nilable(Operand))
      @next_use = T.let(nil, T.nilable(Operand))

      set!(target) if target
    end

    # The operation that this operand belongs to.
    sig { returns(T.nilable(Operation)) }
    attr_accessor :parent_operation

    sig { returns(Operation) }
    def parent_operation!
      T.must(@parent_operation)
    end

    # This operand's index in the operation's operand array.
    sig { returns(T.nilable(Integer)) }
    def index
      @parent_operation&.operands&.find_index(self)
    end

    # The previous operand in the target value's list of uses.
    sig { returns(T.nilable(Operand)) }
    attr_accessor :prev_use

    # The next operand in the target value's list of uses.
    sig { returns(T.nilable(Operand)) }
    attr_accessor :next_use

    # This operand's target value, if set. Otherwise, nil.
    sig { returns(T.nilable(Value)) }
    def get
      @target
    end

    # This operand's target value. Target must be set.
    sig { returns(Value) }
    def get!
      T.must(@target)
    end

    # True if this operand's target is set.
    sig { returns(T::Boolean) }
    def set?
      @target != nil
    end

    # True if the operand's target is not set.
    sig { returns(T::Boolean) }
    def unset?
      @target.nil?
    end

    # True if this operand is targeting x.
    sig { params(x: Value).returns(T::Boolean) }
    def is?(x)
      @target.equal?(x)
    end

    # Set the target value of this operand. Target must not be already set.
    sig { params(target: Value).void }
    def set!(target)
      raise "operand target already set" unless @target.nil?

      @target = target
      @next_use = target.first_use
      @next_use.prev_use = self if @next_use
      target.first_use = self
    end

    # Clear this operand. Operand must be set. See-also: drop!
    sig { void }
    def unset!
      raise "operand target already unset" if @target.nil?

      if @target.first_use == self
        @target.first_use = @next_use
      end

      @prev_use.next_use = @next_use if @prev_use
      @next_use.prev_use = @prev_use if @next_use

      @target = nil
      @prev_use = nil
      @next_use = nil
    end

    # Reset this operand to target a new value.
    sig { params(target: T.nilable(Value)).void }
    def reset!(target)
      unset! if set?
      set!(target) if target
    end

    # Clear this operand, if it is set.
    sig { void }
    def drop!
      unset! if set?
    end

    # Copy this operand into another operation.
    sig { params(operation: Operation).returns(Operand) }
    def copy_into(operation)
      operation.new_operand(get)
    end
  end
end
