require 'bagit'
require 'fileutils'

module Hull
  module Bagit

    def create_bag(path, admin_info, description_file_path=nil)

      #create the temporary directory
      FileUtils::mkdir_p 'hull_bagit_temp'
      FileUtils::mkdir_p 'hull_bagit_temp/content'
      FileUtils::mkdir_p 'hull_bagit_temp/admin_info'

      #put the data in the correct folder
      if path[-1] === "/"
        FileUtils.cp_r(path, 'hull_bagit_temp/content/')
      else
        path += "/"
        FileUtils.cp_r(path, 'hull_bagit_temp/content/')
      end

      #create the admin info file in the admin info directory
      File.open("hull_bagit_temp/admin_info/admin_info.txt") do |f|
        f.write(admin_info)
      end

      #if there is no description file, let the watcher specify where to get the description from
      unless File.file?('hull_bagit_temp/content/description.txt') || File.file?('hull_bagit_temp/content/description.csv')
        FileUtils.cp(description_file_path, 'hull_bagit_temp/content/')
      end


      #reads in descriprion.csv and updates it if necessary
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

      #create a bag from the temporary directory
      BagIt::Bag.new('hull_bagit_temp')

      #delete the temporary directory
      FileUtils.rm_rf('hull_bagit_temp')

    end
  end
end
