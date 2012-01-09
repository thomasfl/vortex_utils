# -*- coding: utf-8 -*-
require_relative 'helper'

class TestStringExtensions < Test::Unit::TestCase

  should "transliterate accents nicesly" do
    assert "ñâñôñä".transliterate_accents == "nanona"
  end

  should "snake case sentences" do
    assert "one two three".snake_case == "one-two-three"
  end

  should "make sentences into strings usable for readable urls" do
    assert "this is a çircûmflexed senteñce".to_readable_url == "this-is-a-circumflexed-sentence"
  end

end
