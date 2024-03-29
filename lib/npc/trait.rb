# typed: strict
# frozen_string_literal: true

module NPC
  # A mixin in NPC for IR objects.
  module Trait
    extend T::Sig
    extend T::Helpers
  end

  # A mixin for an operation.
  module OperationTrait
    extend T::Sig
    extend T::Helpers
    include Trait
    abstract!

    requires_ancestor { NPC::Operation }
  end

  # A mixin for a type.
  module TypeTrait
    extend T::Sig
    extend T::Helpers
    include Trait
    abstract!

    requires_ancestor { NPC::Type }
  end
end
