require 'fakefs/spec_helpers'
require 'rspec'
require 'csv'
require_relative '../../lib/hull/bagit_helpers.rb'
require_relative '../../lib/hull_bagit.rb'

include RSpec

describe HullBagit do

  include FakeFS::SpecHelpers

  context 'create and read a bag' do

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
      expect(info[:description]).to match_array(["1,Nev_#{DateTime.now.strftime("%d-%b-%Y")},Nev", "2,Nev_#{DateTime.now.strftime("%d-%b-%Y")},Nev","3,Nev_#{DateTime.now.strftime("%d-%b-%Y")},Nev"])
      expect(info[:content]).to match_array([".", "..", "description.csv", "random_file.txt"])
    end

    it 'raises an error if an attempt is made to create a bag where there already is one' do
      expect{HullBagit.new(@dir_name, {:author_name => "Nev"})}.to raise_error("There already is a bag at #{@dir_name}")
    end

    it 'raises an error if an attempt is made to read a bag where one does not exist' do
      @no_bag = '/no_bag'
      FileUtils::mkdir(@no_bag)

      expect{HullBagit.read(@no_bag)}.to raise_error("There is no bag at #{@no_bag}.")
    end
  end

  context 'create a bag when there is no description file in target folder' do

    before do

      @dir_name = '/bagging'
      FileUtils::mkdir(@dir_name)

      File.open(@dir_name + "/random_file.txt", "wb") do |f|
        f.write("Random contents")
      end
    end


    it 'gets the description from the specified path' do
      @desc_dir = '/desc'
      FileUtils::mkdir(@desc_dir)

      File.open(@desc_dir + "/description.txt", "wb") do |f|
        f.write("Random contents")
      end

      @bag = HullBagit.new(@dir_name, {:author_name => "Nev"}, description_file_path=File.join(@desc_dir, "description.txt"))

      expect(File).to exist(@dir_name+"/data/content/description.txt")

    end

    it 'raises an error when there is no description and no specified path' do
      expect{HullBagit.new(@dir_name, {:author_name => "Nev"})}.to raise_error("Couldn't find a description file.")
    end

    it 'raises an error when the specified path does not exist' do
      @no_desc_dir = '/no_desc'
      FileUtils::mkdir(@no_desc_dir)

      expect{HullBagit.new(@dir_name, {:author_name => "Nev"}, description_file_path=@no_desc_dir+"/description.txt")}.to raise_error("No such file or directory - #{@no_desc_dir+"/description.txt"}")
    end
  end

end