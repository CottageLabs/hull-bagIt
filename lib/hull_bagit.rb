require 'bagit'
require 'fileutils'

class HullBagit

  include Hull::BagitHelpers

  def initialize(path, admin_info, description_file_path=nil)

    @temp_dir, @content_temp_dir, @admin_info_temp_dir = create_temp_directory
    move_data(path, @content_temp_dir)
    create_admin_info(admin_info)

    if description_file_path
      move_description(description_file_path)
    end

    process_description(@content_temp_dir, admin_info)

    Dir.glob(File.join(@temp_dir, '*')).each do |file|
      FileUtils.mv(file, path)
    end

    #delete the temporary directory
    FileUtils.rm_rf(@temp_dir)

    #create a bag from the temporary directory
    bag = BagIt::Bag.new(path)

    bag.add_directory('content', Dir.glob(File.join(path, 'content')))
    bag.add_directory('admin_info', Dir.glob(File.join(path, 'admin_info')))

    FileUtils.rm_rf(Dir.glob(File.join(path, 'content')))
    FileUtils.rm_rf(Dir.glob(File.join(path, 'admin_info')))

    bag.manifest!

    bag

  end

  def self.read(bag_path)
    bag_info = {}
    bag_info[:admin_info] = self.get_admin_info(bag_path)
    bag_info[:description] = self.get_description(bag_path)
    bag_info[:content] = self.get_content_list(bag_path)

    bag_info
  end

  def self.get_admin_info(bag_path)
    admin_info = File.open(
        Dir.glob(
            File.join(bag_path, "data/admin_info/admin_info.txt"))[0])
    info = []
    admin_info.each_line do |line|
      info << line.strip
    end
    info
  end

  def self.get_content_list(bag_path)
    content_dir = Dir.glob(File.join(bag_path, "data/content"))[0]
    entries = []
    Dir.entries(content_dir).each do |entry|
      entries << entry.strip
    end
    entries
  end

  def self.get_description(bag_path)
    desc = File.open(Dir.glob(File.join(bag_path, "data/content/description.*"))[0])
    description = []
    desc.each_line do |line|
      description << line.strip
    end
    description
  end
end
