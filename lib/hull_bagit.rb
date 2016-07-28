require 'bagit'
require 'fileutils'

class HullBagit

  include Hull::BagitHelpers

  def initialize(path, admin_info, description_file_path=nil)

    create_temp_directory
    move_data(path, 'hull_bagit_temp/content/')
    create_admin_info(admin_info)
    create_description(description_file_path)
    process_description('hull_bagit_temp/content/', admin_info)

    #create a bag from the temporary directory
    BagIt::Bag.new('hull_bagit_temp')

    #delete the temporary directory
    FileUtils.rm_rf('hull_bagit_temp')

  end
end
