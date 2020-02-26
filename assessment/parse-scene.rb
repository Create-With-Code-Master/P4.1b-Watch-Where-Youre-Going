#!/usr/bin/env ruby

# Convert serialized Unity scene files (.unity) into valid YAML.

require 'optparse'

@opts = {
  unity_tag: '%TAG !u! tag:unity3d.com,2011:'
}

scene_file = ARGV.pop

in_doc = false
File.readlines(scene_file).each do |line|
  if (in_doc && line.match(/^--- !u!/))
    # Add a tag directive befor each document after the first.
    puts "...\n#{@opts[:unity_tag]}"
    # Remove trailing strings after document ID.
    line.gsub!(/ [a-z]+$/, '')
  end
  puts line
  in_doc = true if (!in_doc && line.match(/^--- !u!/))
end
