require 'fakefs/spec_helpers'
require 'rspec'
require 'csv'
require_relative '../../lib/hull/bagit_helpers.rb'
require_relative '../../lib/hull_bagit.rb'

include RSpec

describe HullBagit do

  include FakeFS::SpecHelpers

  before do

    @dir_name = '/bagging'
    FileUtils::mkdir(@dir_name)
    
    File.open(@dir_name + "/random_file.txt", "wb") do |f|
      f.write("Random contents")
    end

    CSV.open(@dir_name + "/description.csv", "w") do |csv|
      (1..3).each do |i|
        csv << [i]
      end
    end

    @bag = HullBagit.new(@dir_name, {:author_name => "Nev"})
  end


  it 'creates a bag of the correct structure' do
    expect(File).to exist(@dir_name+"/data")
    expect(File).to exist(@dir_name+"/data/content")
    expect(File).to exist(@dir_name+"/data/content/random_file.txt")
    expect(File).to exist(@dir_name+"/data/content/description.csv")
    expect(File).to exist(@dir_name+"/data/admin_info")
    expect(File).to exist(@dir_name+"/data/admin_info/admin_info.txt")

    expect(File).to exist(@dir_name+"/bag-info.txt")
    expect(File).to exist(@dir_name+"/bagit.txt")
    expect(File).to exist(@dir_name+"/manifest-md5.txt")
    expect(File).to exist(@dir_name+"/tagmanifest-md5.txt")
    expect(File).to exist(@dir_name+"/manifest-sha1.txt")
    expect(File).to exist(@dir_name+"/tagmanifest-sha1.txt")
  end

  it 'reads the bag information' do
    info = HullBagit.read(@dir_name)

    expect(info[:admin_info]).to match_array(["author_name: Nev"])
    expect(info[:description]).to match_array(["1,Nev_05-Aug2016,Nev", "2,Nev_05-Aug2016,Nev","3,Nev_05-Aug2016,Nev"])
    expect(info[:content]).to match_array([".", "..", "description.csv", "random_file.txt"])
  end

end