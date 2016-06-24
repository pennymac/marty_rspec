RSpec::Matchers.define :netzke_include do |expected|
  match do |actual|
    parsed_values = actual.each_with_object({}) do | (k, v), h |
      h[k] = v == "False" ? false : v
    end
    expect(parsed_values).to include(expected.stringify_keys)
  end

  diffable
end
