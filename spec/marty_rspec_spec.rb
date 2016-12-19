require 'spec_helper'

describe MartyRSpec do
  it 'has a version number' do
    expect(MartyRSpec::VERSION).not_to be nil
  end

  it 'get the grid name' do
    foo_grid = netzke_find('foo')
    expect(foo_grid.name).to eq 'foo'
  end

  it 'escape util function works' do
    some_string = "blah\tblah\n"
    expect(simple_escape(some_string)).to eq "blah\\tblah\\n"
  end
end
