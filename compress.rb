# to run this file check the following commands:
# gem install rubyzip
# gem install zip
require 'rubygems'
require 'zip/zip'

unless ARGV[0]
	puts "Usage: ruby compress.rb <filename.ext>"
	puts "Example: ruby compress.rb myfile.exe"
	exit
end

file = ARGV[0].chomp

if File.exist?(file)
	print "Enter zip filename: "
	zip = "#{$stdin.gets.chomp}.zip"
	Zip::ZipFile.open(zip, true) do |zipfile|
		begin 
			puts "#{file} is being added to the archive."
			zipfile.add(file, file)
		rescue Exception => e 
			puts "Error adding to zipfile: \n#{e}"
		end
	end
else
	puts "\nFile could not be found."
end

