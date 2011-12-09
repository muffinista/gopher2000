# -*- coding: utf-8 -*-
# require File.join(File.dirname(__FILE__), '/spec_helper')

# describe String, '#wrap' do
#   it 'should wrap ab cd e to ab' do
#     "ab cd e".wrap(2).should == "ab\ncd\ne"
#   end

#   it 'should not wrap lines with no spaces' do
#     "abcde".wrap(2).should == "abcde"
#   end

#   it 'should yield wrapped lines when called with a block' do
#     array = []
#     "ab cd efg".wrap(2) do |line|
#       array << line
#     end
#     array.should == ["ab", "cd", "efg"]
#   end

#   it 'should handle unicode strings' do
#     "å å".wrap(3).should == "å å"
#   end
# end
