Gem::Specification.new do |s|
  s.name        = 'playlist_transfer'
  s.version     = '0.0.1'
  s.date        = '2016-10-18'
  s.summary     = "Transfers music (defined by M3U playlist) from your music library to destination folder - including directory structure"
  s.description = "Transfers your music (FLAC and MP3) to destination folder (for example USB drive). It can convert all to MP3 files, or leave as is and just copy files-"
  s.authors     = ["Kisuke"]
  s.email       = 'kisuke@kisuke.cz'
  s.files       = ["lib/musictrack.rb", "lib/musictrack/extensions.rb"]
  s.executables << 'playlist_transfer'
  s.homepage    = 'https://github.com/Kisuke-CZE/playlist_transfer'
end
