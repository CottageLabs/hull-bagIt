require 'bagit'
require 'fileutils'

module Hull
  module Bagit

    def create_bag(path, admin_info, description_file_path=nil)

      create_temp_directory
      move_data(path, 'hull_bagit_temp/content/')
      create_admin_info(admin_info)

      #if there is no description file, let the watcher specify where to get the description from
      unless File.file?('hull_bagit_temp/content/description.txt') || File.file?('hull_bagit_temp/content/description.csv')
        FileUtils.cp(description_file_path, 'hull_bagit_temp/content/')
      end

      process_description(admin_info)

      #create a bag from the temporary directory
      BagIt::Bag.new('hull_bagit_temp')

      #delete the temporary directory
      FileUtils.rm_rf('hull_bagit_temp')

    end

    def create_temp_directory

      #create the temporary directory
      FileUtils::mkdir_p 'hull_bagit_temp'
      FileUtils::mkdir_p 'hull_bagit_temp/content'
      FileUtils::mkdir_p 'hull_bagit_temp/admin_info'
    end

    def move_data(from, to)
      #put the data in the correct folder
      if from[-1] === "/"
        FileUtils.cp_r(from, to)
      else
        from += "/"
        FileUtils.cp_r(from, to)
      end
    end

    def create_admin_info(admin_info)
      #create the admin info file in the admin info directory
      File.open("hull_bagit_temp/admin_info/admin_info.txt") do |f|
        f.write(admin_info["author_name"])
      end
    end

    def process_description(admin_info)

      #reads in description.csv and updates it if necessary
      if File.file?('hull_bagit_temp/content/description.csv')
        new_description = CSV::Writer.generate(File.open('new_description.csv', 'wb'))
        CSV.foreach('hull_bagit_temp/content/description.csv') do |row|
          if row.size <= 1
            new_row = [row[0], admin_info["author_name"] + "_" + Date.now.strftime("%d-%b%Y"), admin_info["author_name"]]
            new_description << new_row
          end
        end
        new_description.close

        File.rename('hull_bagit_temp/content/description.csv', 'hull_bagit_temp/content/old_description.csv')
        File.rename('hull_bagit_temp/content/new_description.csv', 'hull_bagit_temp/content/description.csv')
        File.delete('hull_bagit_temp/content/old_description.csv')
      end

    end
  end
end
