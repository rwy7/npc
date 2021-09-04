# typed: strict
# frozen_string_literal: true

module NPC
  # The core set of IR in NPC.
  module Core
    extend T::Sig
  end
end

require_relative("core/call")
require_relative("core/const")
require_relative("core/function")
require_relative("core/i32_add")
require_relative("core/i32_const")
require_relative("core/i32")
require_relative("core/module")
