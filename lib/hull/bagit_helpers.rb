require 'bagit'
require 'fileutils'
require 'csv'

module Hull
  module BagitHelpers
    def create_temp_directory

      #create the temporary directory
      FileUtils::mkdir_p 'hull_bagit_temp'
      FileUtils::mkdir_p 'hull_bagit_temp/content'
      FileUtils::mkdir_p 'hull_bagit_temp/admin_info'
    end

    def move_data(from, to)
      #put the data in the correct folder
      if from[-1] === "/"
        from += "."
        FileUtils.cp_r(from, to)
      else
        from += "/."
        FileUtils.cp_r(from, to)
      end
    end

    def create_admin_info(admin_info)
      #create the admin info file in the admin info directory
      File.open("hull_bagit_temp/admin_info/admin_info.txt", "w") do |f|
        f.write(admin_info["author_name"])
      end
    end

    def create_description(description_file_path)
      #if there is no description file, let the watcher specify where to get the description from
      unless File.file?('hull_bagit_temp/content/description.txt') || File.file?('hull_bagit_temp/content/description.csv')
        FileUtils.cp(description_file_path, 'hull_bagit_temp/content/')
      end

    end

    def process_description(content_directory, admin_info)

      #reads in description.csv and updates it if necessary
      if File.file?(content_directory+"description.csv")
        CSV.open(content_directory + 'new_description.csv', 'wb') do |csv|
          CSV.foreach(content_directory+"description.csv") do |row|
            if row.size <= 1
              new_row = [row[0], admin_info[:author_name] + "_" + DateTime.now.strftime("%d-%b%Y"), admin_info[:author_name]]
              csv << new_row
            end
          end
        end
      end


      File.rename(content_directory+"description.csv", content_directory+"old_description.csv")
      File.rename(content_directory+"new_description.csv", content_directory+"description.csv")
      File.delete(content_directory+"old_description.csv")

    end
  end
end