# Hull::Bagit

This gem creates a Bag from a directory following University of Hull structure requirements.

## Installation

Add this line to your application's Gemfile:

    gem 'hull-bagit', :git => "https://github.com/CottageLabs/hull-bagit", :branch => "master"

And then execute:

    $ bundle install

## Usage

    require 'hull-bagit'
    
    # supply the directory you wish bagged. 
    # Any admin information should come as a hash after the path.
    bag = HullBagit.new(dir_name, {:author_name => "Author"})
    
    # if there is no description file in the directory to bag, you can supply a path from which the library should take
    # the description
    bag = HullBagit.new(dir_name, {:author_name => "Author Name"}, description_file_path=path)
    
    # to examine the bag
    bag_info = HullBagit.read(path_to_bag)
    
    # this returns a hash with the following keys:
    # bag_info[:content] - list of all the content file paths
    # bag_info[:admin_info] - list of all the lines in the admin txt
    # bag_info[:description] - list of all the lines in the description file.    
    

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
