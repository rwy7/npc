# typed: true
# frozen_string_literal: true

# Dependencies

require("sorbet-runtime")
require("pp")

# The Basics

module NPC
  extend T::Sig
  extend T::Helpers

  class << self
    extend T::Sig
    extend T::Helpers
  end
end

# Base Library

require("npc/argument")
require("npc/base")
require("npc/block_sentinel")
require("npc/block")
require("npc/builder")
require("npc/in_block")
require("npc/located")
require("npc/location")
require("npc/operand")
require("npc/operation")
require("npc/pp")
require("npc/pure")
require("npc/region")
require("npc/storage")
require("npc/trait")
require("npc/type")
require("npc/use")
require("npc/users")
require("npc/uses")
require("npc/value")

# IR Dialects

require("npc/core")
