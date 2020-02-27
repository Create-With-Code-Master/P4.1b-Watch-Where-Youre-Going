gem 'minitest'

require 'minitest/autorun'
require 'minitest/pride'
require_relative '../auto-score'

require 'date'

class AutoScoreTest < Minitest::Test
  def setup
    @d = "test-tmp"
    %x( mkdir #{@d} )
    %x( cd #{@d} ; git init ; )
    branches = %w[ lesson-1 lesson1 lesson_1 lesson2 ]
    branches.each do |b|
      %x( cd #{@d} ; git checkout -b #{b} 2> /dev/null ; touch foo ; git add . ; git commit -m 'bar' )
    end
  end

  def test_find_branch_returns_an_exact_match_when_one_exists
    branch = find_branch(@d, 'lesson-1')
    assert_equal 'lesson-1', branch
  end

  def test_find_branch_finds_a_close_match
    branch = find_branch(@d, 'lesson-2')
    assert_equal 'lesson2', branch
  end

  def test_find_branch_returns_nil_when_no_match_exists
    branch = find_branch(@d, 'non-existant-branch')
    assert_nil branch
  end

  def teardown
    %x( rm -rf #{@d} )
  end
end
