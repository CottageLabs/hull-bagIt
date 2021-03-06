require 'bagit'
require 'fileutils'
require 'csv'
require 'tmpdir'

module Hull
  module BagitHelpers
    def create_temp_directory

      #create the temporary directory
      @temp_dir = Dir.mktmpdir('/hull_bagit_temp')

      @content_temp_dir = @temp_dir+'/content'
      FileUtils::mkdir(@content_temp_dir)

      @admin_info_temp_dir = @temp_dir+'/admin_info'
      FileUtils::mkdir(@admin_info_temp_dir)

      return @temp_dir, @content_temp_dir, @admin_info_temp_dir
    end

    def move_data(from, to)
      #put the data in the correct folder
      Dir.glob(File.join(from, '*')).each do |file|
        FileUtils.mv(file, to)
      end
    end

    def create_admin_info(admin_info)
      #create the admin info file in the admin info directory
      File.open(@admin_info_temp_dir+ "/admin_info.txt", "w") do |f|
        admin_info.each do |k,v|
          f.puts("#{k}: #{v}")
        end
      end
    end

    def move_description(description_file_path)
      #if there is no description file, let the watcher specify where to get the description from
      unless File.file?(File.join(@content_temp_dir,'/description.txt')) || File.file?(File.join(@content_temp_dir,'/description.csv'))
        FileUtils.mv(description_file_path, @content_temp_dir)
      end
    end

    def process_description(content_directory, admin_info)

      unless File.file?(File.join(content_directory,'/description.txt')) || File.file?(File.join(content_directory,'/description.csv'))
        raise "Couldn't find a description file."
      end

      #reads in description.csv and updates it if necessary
      if File.file?(content_directory+"/description.csv")
        CSV.open(content_directory + '/new_description.csv', 'wb') do |csv|
          CSV.foreach(content_directory+"/description.csv") do |row|
            if row.size <= 1 || (row[1] == "" && row[2] == "")
              new_row = [row[0], admin_info[:author_name] + "_" + DateTime.now.strftime("%d-%b-%Y"), admin_info[:author_name]]
              csv << new_row
            end
          end
        end

        File.rename(content_directory+"/description.csv", content_directory+"/old_description.csv")
        File.rename(content_directory+"/new_description.csv", content_directory+"/description.csv")
        File.delete(content_directory+"/old_description.csv")
      end

    end
  end
end