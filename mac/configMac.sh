sudo ln -s /usr/include/malloc/malloc.h /usr/include/malloc.h
defaults write com.apple.dashboard mcx-disabled -boolean YES
defaults write com.apple.CrashReporter DialogType none
defaults write com.apple.dock itunes-notifications -bool TRUE
defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES
defaults write com.apple.finder QuitMenuItem -bool YES
defaults write com.apple.Dock showhidden -bool YES
defaults write -g PMPrintingExpandedStateForPrint -bool TRUE
defaults write com.apple.iTunes invertStoreLinks -bool YES
defaults write com.apple.dashboard devmode YES
defaults write -g NSNavPanelExpandedStateForSaveMode -bool TRUE
defaults write com.apple.LaunchServices LSQuarantine -bool NO
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
defaults write com.apple.Finder QuitMenuItem 1
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist
killall Finder
killall Dock
echo "Are paths set up?"
