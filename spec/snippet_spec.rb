# encoding: utf-8

require 'spec_helper'

describe "add_tags" do
  it "should add a tag" do
    lambda do
      @basic_snippet.add_tags('tag1')
    end.should change(@basic_snippet.tags, :size).by(1)
  end

  it "should not add the tag if the snippet already has it" do
    lambda do
      @basic_snippet.add_tags('hello')
    end.should_not change(@basic_snippet.tags, :size)
  end
end
