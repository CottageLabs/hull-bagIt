require 'fakefs/spec_helpers'
require 'rspec'

include RSpec

describe Hull::Bagit do
  include FakeFS::SpecHelpers

  it 'creates the temporary directories' do
    Hull::Bagit.create_temp_directory

    expect(File).to exist("hull_bagit_temp")
    expect(File).to exist("hull_bagit_temp/content")
    expect(File).to exist("hull_bagit_temp/admin_info")
  end

  it 'moves the data to the temp directories' do

  end

  it 'creates the admin info file' do

  end

  it 'processes the description file if necessary' do

  end

  it 'creates the bag' do

  end

  it 'deletes the temp directory' do

  end
end