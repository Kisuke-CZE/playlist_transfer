Gem::Specification.new do |s|
  s.add_runtime_dependency 'm3u8', '>=0.6.9'
  s.add_runtime_dependency 'activesupport', '>=5.0.0'
  s.name        = 'playlist_transfer'
  s.version     = '0.0.3'
  s.date        = '2019-06-10'
  s.summary     = "Transfers music (defined by M3U playlist) from your music library to destination folder - including directory structure"
  s.description = "Transfers your music (from m3u playlist) to destination folder (for example USB drive). It can convert your FLAC files to MP3 files, or leave as is and just copy files-"
  s.authors     = ["Kisuke"]
  s.email       = 'kisuke@kisuke.cz'
  s.files       = ["lib/playlist_transfer.rb", 'README.md', "lib/playlist_transfer/extensions.rb"]
  s.executables << 'playlist_transfer'
  s.homepage    = 'https://github.com/Kisuke-CZE/playlist_transfer'
  s.license     = 'WTFPL'
end
