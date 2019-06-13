require 'pathname'
require 'tempfile'
require 'playlist_transfer/extensions'

# Class MusicTrack represents one audiofile (trackfile) in some "Music folder" (basedir).
# trackfile and basedir are Pathnames
class MusicTrack
  # Class MusicTrack represents one audiofile (trackfile) in some "Music folder" (basedir).
  def initialize(trackfile,basedir)
    abort "File #{trackfile.expand_path} is not located in #{basedir.expand_path}" if !trackfile.expand_path.is_child?(basedir.expand_path)
    @path = trackfile.expand_path
    @basedir = basedir.expand_path
  end

# Methods flactags and encode_flac are highly inspired by script from guy named Mathew who posted his script on github: https://gist.github.com/lpar/4645195

# Method get_tags returns an array with tags extracted from original FLAC file. Array has fields named as attributes from original file. Each field contains value of that attribute
  def get_tags
  tmpfile = Tempfile.new('flacdata')
  system(
    'metaflac',
    "--export-tags-to=#{tmpfile.path}",
    '--no-utf8-convert',
    @path.to_s
  )
  data = tmpfile.open
  tags = { 'title' => '', 'artist' => '', 'album' => '', 'date' => '', 'tracknumber' => '0' }
  while line = data.gets
    m = line.match(/^(\w+)=(.*)$/)
    if m && m[2]
      tags[m[1].downcase] = m[2]
    end
  end
  return tags
  end

# Method encode_flac transcodes FLAC file to MP3 file placed in output (which is passed as parameter).
# Parameter output should be Pathname
  def encode_flac(outputfile)
  wavtemp = Tempfile.new('wavfile')
  info = self.get_tags
  track = info['tracknumber'].gsub(/\D/,'')
  system(
    'flac',
    '-s',
    '-d',
    '-f',
    '-o',
    wavtemp.path,
    @path.to_s
  )
  system(
    'lame',
    '--silent',
    '--replaygain-accurate',
    '--preset', 'cbr', '320',
    '-m', 's',
    '-q', '0',
    '--add-id3v2',
    '--tt', info['title'],
    '--ta', info['artist'],
    '--tl', info['album'],
    '--ty', info['date'],
    '--tn', track,
    '--tg', info['genre'] || 'Rock',
    wavtemp.path,
    outputfile.to_s
  )

  # If encoding process is interrupted (by pressinc Ctrl + C), remove probably incomplete file in destination.
  rescue Interrupt
  FileUtils.rm(outputfile) if outputfile.file?
  abort "Interrupted when encoding #{outputfile}. Incomplete file removed from destination."
  end

  # Returns true if track type is FLAC. Identified by file extension.
  def is_flac?
    if @path.extname.downcase == ".flac"
      return true
    else
      return false
    end
  end

  # This method transfers track file to destination (outfile parameter is Pathname). (When it is FLAC, it converts it to MP3 by default, other files will be just copied).
  # You can specify that you do not want to convert FLAC to MP3 by adding second parameter (justcopy) with value "true".
  # It also creates directory structure (relatively from basedir to track itself) in destination.
  def filetransfer(outfile, justcopy = nil, skoda = nil, relative_path = nil, output = nil)
    abort "File #{@path.to_s} does not exist."  if !@path.file?
    outfile = outfile.sub(/\.flac$/i, '.mp3') if !justcopy
    # If file in destination already exists in destination, skip it, no need to tranfer it.
    if !outfile.file?
      puts "Transfering #{outfile.to_s}"
      outfile.dirname.mkpath
      if self.is_flac? && !justcopy
        self.encode_flac(outfile)
      else
        FileUtils.cp(@path.realpath,outfile)
      end
      # Quick and dirty fix for stuid SKODA audio system, to be able to shuffle all music on storage (Not just in folder like it usualy does)
      if skoda
        playlist_line = "/" + relative_path.to_s
        open("#{output}/ALL_MUSIC.M3U", 'a') { |f|
          f.puts playlist_line
        }
      end
    else
      puts "File #{outfile.to_s} already exists. Skipping..."
    end
  end

  # Method to transfer file and it's directory structure to destination (output)
  # You can specify you want to create directory srtucture in destination in "compatible" way. This means no spaces and special characters in filenames.
  # If you do not want any conversion from FLAC to MP3, just set justcopy to true.
  def transfer(output, compatible = nil, justcopy = nil, skoda = nil)
    abort "Can't write to #{output.to_s} or it is not directory." unless output.expand_path.directory? && output.expand_path.writable?

    # Next 3 lines just creates complete destination path for transfered track (combining desired output directory, current track location, and basedir). It also removes special characters if necessary.
    relative_path = @path.relative_path_from(@basedir)
    relative_path = relative_path.no_special_chars if compatible
    output_file = output.expand_path + relative_path

    self.filetransfer(output_file, justcopy, skoda, relative_path, output.expand_path)
  end

  # Method to transfer file and it's structure in "compatible" way (file and it's directory structure with removed special characters) - just alias for transfer with proper parameters.
  def transfer_compatible(output, justcopy = nil)
    self.transfer(output, true, justcopy)
  end

  # Method to transfer file and it's structure without removing special characters or transcoding files to MP3 - just alias for transfer with proper parameters.
  def just_copy(output)
    self.transfer(output, nil, true)
  end
end
