# typed: true
# frozen_string_literal: true

require_relative("test")

class TestDominatorTree < MiniTest::Test
  extend T::Sig

  def test_single_block
    m = NPC::ExIR::Module.build("example")
    b = m.region(0).first_block!

    tree = NPC::DominatorTree.new(m.region(0))
    n = tree.node(b)

    assert_nil(n.parent)
    assert_equal(b,  n.block)
    assert_equal(0,  n.index)
    assert_empty(n.children)
    assert_nil(NPC::VerifyDominance.call(m))

    iter = NPC::PostOrderGraphIter.new(n)
    assert_equal([n], iter.to_a!)
  end

  sig { void }
  def test_linear_cfg
    m = NPC::ExIR::Module.build
    f = NPC::ExIR::Function.build
    m.region(0).first_block!.append_operation!(f)
    r = f.region(0)

    b0 = r.first_block!
    b1 = NPC::Block.new.insert_into_region!(r.back)

    b0.append_operation!(NPC::ExIR::Goto.build(b1))

    tree = NPC::DominatorTree.new(r)

    n0 = tree.node(b0)
    n1 = tree.node(b1)

    assert_nil(n0.parent)
    assert_equal(b0,   n0.block)
    assert_equal(1,    n0.index)
    assert_equal([n1], n0.children)

    assert_equal(n0, n1.parent)
    assert_equal(b1, n1.block)
    assert_equal(0,  n1.index)
    assert_empty(n1.children)

    iter = NPC::PostOrderGraphIter.new(n0)
    assert_equal([n1, n0], iter.to_a!)
  end

  def test_diamond_cfg
    m = NPC::ExIR::Module.build
    f = NPC::ExIR::Function.build
    m.region(0).first_block!.append_operation!(f)
    r = f.region(0)

    b0 = r.first_block!
    b1 = NPC::Block.new.insert_into_region!(r.back)
    b2 = NPC::Block.new.insert_into_region!(r.back)
    b3 = NPC::Block.new.insert_into_region!(r.back)

    t = NPC::ExIR.const.build(1)

    b0.append_operation!(t)
    b0.append_operation!(NPC::ExIR::GotoN.build(t.result(0), b1, b2))
    b1.append_operation!(NPC::ExIR::Goto.build(b3))
    b2.append_operation!(NPC::ExIR::Goto.build(b3))

    tree = NPC::DominatorTree.new(r)

    n0 = tree.node(b0)
    n1 = tree.node(b1)
    n2 = tree.node(b2)
    n3 = tree.node(b3)

    assert_nil(n0.parent)
    assert_equal(b0, n0.block)
    assert_equal(3, n0.index)
    assert_equal([n2, n1, n3], n0.children)

    assert_equal(n0, n1.parent)
    assert_equal(b1, n1.block)
    assert_equal(1,  n1.index)
    assert_empty(n1.children)

    assert_equal(n0, n2.parent)
    assert_equal(b2, n2.block)
    assert_equal(2,  n2.index)
    assert_empty(n2.children)

    assert_equal(n0, n3.parent)
    assert_equal(b3, n3.block)
    assert_equal(0,  n3.index)
    assert_empty(n3.children)

    iter = NPC::PostOrderGraphIter.new(n0)
    assert_equal([n2, n1, n3, n0], iter.to_a!)
  end
end

class TestDominance < MiniTest::Test
  extend T::Sig

  sig { void }
  def test_one_block
  end
end

class TestDominanceVerifier < Minitest::Test
  extend T::Sig

  sig { void }
  def test_valid_single_block
    m = NPC::ExIR::Module.build("example")
    f = NPC::ExIR::Function.build("test", [], [])
      .insert_into_block!(m.region(0).first_block!.back)
    r = f.region(0)

    b0 = r.first_block!

    x = NPC::ExIR::Const.build(123)
    y = NPC::ExIR::Const.build(456)
    z = NPC::ExIR::Add.build(x.result, y.result)

    b0.append_operation!(x)
    b0.append_operation!(y)
    b0.append_operation!(z)

    assert_nil(NPC::VerifyDominance.call(m))
  end

  sig { void }
  def test_valid_diamond
    m = NPC::ExIR::Module.build
    f = NPC::ExIR::Function.build
      .insert_into_block!(m.region(0).first_block!.back)
    r = f.region(0)

    b0 = r.first_block!
    b1 = NPC::Block.new.insert_into_region!(r.back)
    b2 = NPC::Block.new.insert_into_region!(r.back)
    b3 = NPC::Block.new.insert_into_region!(r.back)

    t = NPC::ExIR::Const.build(000)
    x = NPC::ExIR::Const.build(123)
    y = NPC::ExIR::Const.build(456)

    b0.append_operation!(t)
    b0.append_operation!(x)
    b0.append_operation!(y)
    b0.append_operation!(NPC::ExIR::GotoN.build([b1, b2]))
    b1.append_operation!(NPC::ExIR::Goto.build(b3))
    b2.append_operation!(NPC::ExIR::Goto.build(b3))
    b3.append_operation!(NPC::ExIR::Add.build(x.result, y.result))

    assert_nil(NPC::VerifyDominance.call(m))
  end

  sig { void }
  def test_invalid_single_block
    m = NPC::ExIR::Module.build
    f = NPC::ExIR::Function.build
      .insert_into_block!(m.region(0).first_block!.back)
    r = f.region(0)

    b0 = r.first_block!

    x = NPC::ExIR::Const.build(123)
    y = NPC::ExIR::Const.build(456)
    z = NPC::ExIR::Add.build(x.result, y.result)

    b0.append_operation!(z)
    b0.append_operation!(x)
    b0.append_operation!(y)

    error = NPC::VerifyDominance.call(m)
    assert(error)
    e = T.cast(T.must(error).root_cause, NPC::DominanceError)
    assert_equal(z.operand(0), e.operand)
  end

  sig { void }
  def test_invalid_diamond
    m = NPC::ExIR::Module.build
    f = NPC::ExIR::Function.build
      .insert_into_block!(m.region(0).first_block!.back)
    r = f.region(0)

    b0 = r.first_block!
    b1 = NPC::Block.new.insert_into_region!(r.back)
    b2 = NPC::Block.new.insert_into_region!(r.back)
    b3 = NPC::Block.new.insert_into_region!(r.back)

    t = NPC::ExIR::Constant.build(true)
    x = NPC::ExIR::Const.build(123)
    y = NPC::ExIR::Const.build(456)

    b0.append_operation!(t)
    b0.append_operation!(NPC::ExIR::GotoN.build(t.result(0), [b1, b2]))

    b1.append_operation!(x)
    b1.append_operation!(NPC::ExIR::Goto.build(b3))

    b2.append_operation!(y)
    b2.append_operation!(NPC::ExIR::Goto.build(b3))

    z = NPC::ExIR::Add.build(x.result, y.result)
    b3.append_operation!(z)

    error = NPC::VerifyDominance.call(m)&.root_cause
    error = T.cast(error, NPC::DominanceError)
    assert_equal(z.operand(0), error.operand)
  end
end
