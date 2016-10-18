#!/bin/bash
echo "Installing playlist_transfer"
git clone https://github.com/Kisuke-CZE/playlist_transfer.git
cd playlist_transfer
gem build playlist_transfer.gemspec
gem install playlist_transfer
cd ..
