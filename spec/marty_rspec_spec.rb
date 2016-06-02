require 'spec_helper'

describe MartyRspec do
  it 'has a version number' do
    expect(MartyRspec::VERSION).not_to be nil
  end

  it 'get the grid name' do
    foo_grid = MartyRspec::NetzkeGrid.netzke_find('foo')
    expect(foo_grid.name).to eq 'foo'
  end

  it 'escape util function works' do
    some_string = "blah\tblah\n"
    simple_escape!(some_string)
    expect(some_string).to eq "blah\\tblah\\n"
  end
end
