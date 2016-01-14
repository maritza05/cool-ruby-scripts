require 'find'
require 'digest/md5'

unless ARGV[0] and File.directory?(ARGV[0])
	puts "\n\n\nYou need to specify a root directory: changedFiles.rb 
	<directory>\n\n\n"
	exit
end

def create_files_reports(root, name_file)
	file_report = "#{root}/#{name_file}"
end

def check_old_list_file(name_file, oldfile_output)
	if File.exists?(name_file)
		File.rename(name_file, oldfile_output)
		File.open(oldfile_output, 'rb') do |infile|
			while (temp = infile.gets)
				line = /(.+)\s{5,5}(\w{32,32})/.match(temp)
				puts "#{line[1]} ---> #{line[2]}"
				oldfile_hash[line[1]] = line[2]
			end
		end
	end
end

def calculate_md5(root_file)
	Find.find(root_file) do |file|
		next if /^\./.match(file)
		next unless File.file?(file)
		begin
			newfile_hash[file] = Digest::MD5.hexdigest(File.read(file))
		rescue
			puts "Error reading #{file} --- MD5 hash not computed"
		end
	end
end

def create_output_changed_file(file)
	file.each do |infile, md5|
		file.puts "#{file}     #{md5}"
	end
end

def check_for_same_hash(new_hash, old_hash)
	same_hash = new_hash.keys.select{|name_file| 
		new_hash[name_file] == old_hash[file]
	}
	same_hash.each do |name_file|
		new_hash.delete name_file
		old_hash.delete name_file
	end
end

# <------- without methods ------------------------->
root = ARGV[0]
oldfile_hash = Hash.new 
newfile_hash = Hash.new 
file_report = create_files_reports(root, 'analysis_report.txt')
file_output = create_files_reports(root, 'file_list.txt')
oldfile_output = create_files_reports(root, 'file_list.old')

# si ya se ha ejecutado el programa existirá un archivo file_list.txt
if File.exist?(file_output)
	# se renombrará el archivo encontrado a una versión anterior
	File.rename(file_output, oldfile_output)
	# se abre el archivo en modo lectura
	File.open(oldfile_output, 'rb') do |infile|
		# se lee la linea del archivo
		while (temp = infile.gets)
			# se buscan los archivos leidos, se espera el nombre del archivo separado por 5 espacios
			# y el hash con 32 caracteres
			line = /(.+)\s{5,5}(\w{32,32})/.match(temp)
			# se imprime el nombre del archivo así como su hash
			puts "#{line[1]} ---> #{line[2]}"
			# se agrega al hash el nombre del archivo como llave y su md5 como valor
			oldfile_hash[line[1]] = line[2]
		end
	end
end

# si no se ha ejecutado anteriormente vamos a buscar la ruta pasada como parámetro
Find.find(root) do |file|
	# descartamos los archivos que comiencen con un punto
	next if /^\./.match(file)
	# descartamos si no es un archivo o si es un directorio
	next unless File.file?(file)

	begin
		# en el nuevo hash añadimos el nombre del archivo como clave y el md5 del archivo como valor
		newfile_hash[file] = Digest::MD5.hexdigest(File.read(file))
	rescue
		puts "Error reading #{file} --- MD5 hash not computed."
	end
end

# creamos el archivo de reporte en modo de truncado
report = File.new(file_report, 'wb')
# creamos el archivo de salida en modo de truncado
changed_files = File.new(file_output, 'wb')

# llenamos el archivo de salida con el nombre del archivo y su md5
newfile_hash.each do |file, md5|
	changed_files.puts "#{file}     #{md5}"
end

# borramos del archivo aquellos cuyo antiguo md5 sea igual al nuevo
newfile_hash.keys.select {|file| newfile_hash[file] == oldfile_hash[file]
}.each do |file|
	newfile_hash.delete(file)
	oldfile_hash.delete(file)
end

# para cada antiguo hash obtenido si existe su md5 es que ha sido cambiado, sino añadido 
newfile_hash.each do |file, md5|
	report.puts "#{oldfile_hash[file] ? "Changed":"Added"} file: #{file} #{md5}"
	# borramos el archivo del hash
	oldfile_hash.delete(file)
end


oldfile_hash.each do |file, md5|
	report.puts "Deleted/Moved file: #{file}      #{md5}"
end

report.close
changed_files.close
