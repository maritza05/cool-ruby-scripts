require 'zip/zip'
require 'fileutils'

unless ARGV[0]
	puts "Usage: ruby decompress.rb <zipfilename.zip>"
	puts "Example: ruby decompress.rb myfile.zip"
	exit
end

archive = ARGV[0].chomp 

if File.exists?(archive)
	print "Enter path to save files to (\'.\' for same directory): "
	extract_dir = $stdin.gets.chomp 
	begin
		Zip::ZipFile::open(archive) do |zipfile|
			zipfile.each do |f|
				path = File.join(extract_dir, f.name)
				FileUtils.mkdir_p(File.dirname(path))
				zipfile.extract(f, path)
			end
		end
	rescue Exception => e
		puts e 
	end
else
	puts "An error ocurred during descompression: \n #{e}"
end