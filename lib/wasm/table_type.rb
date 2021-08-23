# typed: true
# frozen_string_literal: true

module WASM
  class TableType < T::Struct
    prop :limits, Limits
    prop :elem_type, Symbol, default: :anyfunc
  end
end
