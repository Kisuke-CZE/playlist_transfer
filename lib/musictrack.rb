# Class MusicTrack represents one audiofile (trackfile) in some "Music folder" (basedir).
# trackfile and basedir are Pathnames
require 'pathname'
require 'tempfile'
require 'musictrack/extensions'

class MusicTrack
  def initialize(trackfile,basedir)
    abort "File #{trackfile.expand_path} is not located in #{basedir.expand_path}" if !trackfile.expand_path.is_child?(basedir.expand_path)
    @path = trackfile.expand_path
    @basedir = basedir.expand_path
    @relative_path = @path.relative_path_from(@basedir)
  end

# Methods flactags and encode_flac are just slightly modified methods from guy named Mathew who posted his script on github: https://gist.github.com/lpar/4645195
# Thank you very much for this Mathew. I plan to implements these methods by myself in future. But at this time these methods solved my problem very well. I generaly like the way these methods are written.
  def flactags(filename)
  tmpfile = Tempfile.new('flacdata')
  system(
    'metaflac',
    "--export-tags-to=#{tmpfile.path}",
    '--no-utf8-convert',
    filename.to_s
  )
  data = tmpfile.open
  info = { 'title' => '', 'artist' => '',
  'album' => '', 'date' => '',
  'tracknumber' => '0' }
  while line = data.gets
    m = line.match(/^(\w+)=(.*)$/)
    if m && m[2]
      #puts line
      info[m[1].downcase] = m[2]
    end
  end
  return info
  end

  def encode_flac(filename,mp3name)
  basename = filename.to_s.sub(/\.flac$/i, '')
  wavname = Pathname.new("#{basename}.wav")
  info = self.flactags(filename)
  track = info['tracknumber'].gsub(/\D/,'')
  system(
    'flac',
    '-s',
    '-d',
    '-o',
    wavname.to_s,
    filename.to_s
  )
  system(
    'lame',
    '--silent',
    '--replaygain-accurate',
    '--preset', 'cbr', '320',
    '-q', '0',
    '--add-id3v2',
    '--tt', info['title'],
    '--ta', info['artist'],
    '--tl', info['album'],
    '--ty', info['date'],
    '--tn', track,
    '--tg', info['genre'] || 'Rock',
    wavname.to_s,
    mp3name.to_s
  )
  FileUtils.rm(wavname)

  # If encoding process is interrupted (for example by Ctrl + C), remove temporary file (and possible incomplete file in destination).
  # Prevention for generating "randomly placed" WAV files on my harddrive
  rescue Interrupt
  FileUtils.rm(wavname) if wavname.file?
  FileUtils.rm(mp3name) if mp3name.file?
  abort "Interrupted when encoding #{mp3name}. Tempfiles removed."
  end

  def is_flac?
    if @path.extname.downcase == ".flac"
      return true
    else
      return false
    end
  end

  # This method transfers track file destination (outfile parameter is Pathname) as MP3 file. (Whet it is FLAC, it converts it to MP3, other files will be just copied)
  # It also creates directory structure (from basedir to track itself), but without special characters (Because some MP3 players have issues with reading files/folders with special characters in name)
  def filetransfer(outfile, justcopy = nil)
    abort "File #{@path.to_s} does not exist."  if !@path.file?
    # If file in destination already exists in destination, skip it, no need to tranfer it.
    outfile = outfile.sub(/\.flac$/i, '.mp3') if !justcopy
    if !outfile.file?
      puts "Transfering #{outfile.to_s}"
      outfile.dirname.mkpath
      if self.is_flac? && !justcopy
        self.encode_flac(@path.realpath,outfile)
      else
        FileUtils.cp(@path.realpath,outfile)
      end
    else
      puts "File #{outfile.to_s} already exists. Skipping..."
    end
  end

  # Method to transfer file and it's directory structure as is.
  def transfer(output, compatible = nil, justcopy = nil)
    # Next line just creates complete destination path for transfered track (combining desired output directory, current track location, and basedir).
    abort "Can't write to #{output.to_s} ." if !output.expand_path.directory? || !output.expand_path.writable?
    if compatible
      output_file = output.expand_path + @relative_path.no_special_chars
    else
      output_file = output.expand_path + @relative_path
    end
    self.filetransfer(output_file, justcopy)
  end

  # Method to transfer file and it's structure in "compatible" way (file and it's direcroty structure with removed special characters)
  def transfer_compatible(output, justcopy = nil)
    self.transfer(output, true, justcopy)
  end

  def just_copy(output)
    self.transfer(output, nil, true)
  end
end
