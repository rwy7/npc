# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/minitest-focus/all/minitest-focus.rbi
#
# minitest-focus-1.3.1

class Minitest::Test < Minitest::Runnable
  def self.add_to_filter(name); end
  def self.filtered_names; end
  def self.focus(name = nil); end
  def self.set_focus_trap; end
end
class Minitest::Test::Focus
end