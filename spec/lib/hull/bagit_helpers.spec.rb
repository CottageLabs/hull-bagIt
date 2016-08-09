require 'fakefs/spec_helpers'
require 'rspec'
require 'csv'
require_relative '../../../lib/hull/bagit_helpers.rb'

include RSpec

describe Hull::BagitHelpers do

  include FakeFS::SpecHelpers

  before do
    @bagger_helper = Class.new.extend(Hull::BagitHelpers)
  end

  context 'test individual functionality' do

    before do

      FileUtils::mkdir_p 'rand'

      File.open("/rand/random_file.txt", "wb") do |f|
        f.write("Random contents")
      end

      CSV.open("/rand/description.csv", "w") do |csv|
        (1..3).each do |i|
          csv << [i]
        end
      end

      @temp_dir, @content_temp_dir, @admin_info_temp_dir = @bagger_helper.create_temp_directory
    end

    it 'creates the temporary directories' do

      expect(File).to exist(@temp_dir)
      expect(File).to exist(@temp_dir + "/content")
      expect(File).to exist(@temp_dir + "/admin_info")
      expect(@content_temp_dir).to eql(@temp_dir + "/content")
      expect(@admin_info_temp_dir).to eql(@temp_dir + "/admin_info")

    end

    it 'moves the data to the temp directories' do

      @bagger_helper.move_data("/rand", @content_temp_dir)
      expect(File).to exist(@content_temp_dir + "/random_file.txt")
      expect(File).to exist(@content_temp_dir + "/description.csv")

    end

    it 'creates the admin info file' do

      @bagger_helper.create_admin_info({:author_name => "Nev"})

      expect(File).to exist(@admin_info_temp_dir + "/admin_info.txt")

    end

    it 'processes the description file when necessary' do
      @bagger_helper.move_data("/rand", @content_temp_dir)
      @bagger_helper.process_description(@content_temp_dir, {:author_name => "Nev"})

      CSV.foreach(@content_temp_dir + "/description.csv") do |row|
        expect(row[2]).to eql("Nev")
      end
    end
  end
end