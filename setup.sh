#!/usr/bin/env bash


# Helpful stuff
#
# https://gist.github.com/iainconnor/f9d4964ea4211e794d1d
# https://github.com/thoughtbot/laptop
# https://github.com/donnemartin/dev-setup


# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


###########################################################
# Xcode
###########################################################

# Install Xcode developer command line tool
if test ! $(which xcode-select); then
    echo "Installing Xcode Developer Command Line Tool..."
    xcode-select --install
fi


###########################################################
# Homebrew
###########################################################

# Install Homebrew
if test ! $(which brew); then
    echo "Installing Homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure Homebrew and any packages are up-to-date
brew update && brew upgrade --all && brew cleanup && brew cask cleanup

# Add Homebrew taps
echo "Adding Homebrew taps..."
taps=(
    caskroom/cask
    caskroom/fonts
    caskroom/versions
    homebrew/completions
    homebrew/dupes
    homebrew/php
    homebrew/versions
    phinze/cask
)
brew tap ${taps[@]}

# Install Fonts
echo "Installing Homebrew fonts..."
fonts=(
    font-bebas-neue
    font-hack
    font-lato
    font-open-sans
    font-roboto
    font-ubuntu
    font-vollkorn
)
brew cask install ${fonts[@]}

# Install Packages
echo "Installing Homebrew packages..."
packages=(
    ack
    autojump
    caskroom/cask/brew-cask
    git
    homebrew/php/composer
    heroku-toolbelt
    httpie
    imagemagick
    # mackup
    mycli
    # mysql
    the_silver_searcher
    tree
    vagrant-completion
    wget --with-iri
    homebrew/php/wp-cli
)
brew install ${packages[@]}

brew update && brew upgrade --all && brew cleanup && brew cask cleanup

# Install Casks
echo "Installing Homebrew casks..."
apps=(
    alfred
    appcleaner
    atom
    dropbox
    droplr
    dropshare
    firefox
    flycut
    google-chrome
    google-chrome-canary
    iterm2
    karabiner
    miro-video-converter
    mou
    noizio
    onepassword
    sequel-pro
    sketch
    skype
    slack
    spectacle
    spotify
    spotify-notifications
    steam
    sublime-text3
    the-unarchiver
    transmit
    vagrant
    vagrant-manager
    virtualbox
    vlc
)
brew cask install --appdir="/Applications" ${apps[@]}

# Install quick look plugins
echo "Installing Homebrew quick look plugins..."
quicklook=(
    betterzipql
    qlcolorcode
    qlimagesize
    qlmarkdown
    qlprettypatch
    qlstephen
    quicklook-csv
    quicklook-json
    suspicious-package
    webpquicklook
)
brew cask install ${quicklook[@]}

# Finished with Homebrew stuff
brew update && brew upgrade --all && brew cleanup && brew cask cleanup


###########################################################
# dnsmasq
###########################################################

# Install dnsmasq
brew install dnsmasq
cd $(brew --prefix)
mkdir etc
echo 'address=/.dev/127.0.0.1' > etc/dnsmasq.conf
sudo cp -v $(brew --prefix dnsmasq)/homebrew.mxcl.dnsmasq.plist /Library/LaunchDaemons
sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
sudo mkdir /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/dev'


###########################################################
# Git
###########################################################

# Setup the Git config
GIT_AUTHOR_NAME="Kyle Brumm"
git config --global user.name "$GIT_AUTHOR_NAME"

GIT_AUTHOR_EMAIL="kjbrum@msn.com"
git config --global user.email "$GIT_AUTHOR_EMAIL"

git config --global core.excludesfile ~/.gitignore
git config --global core.attributesfile ~/.gitattributes
git config --global core.editor nano
git config --global core.trustctime false
git config --global init.templatedir ~/.git-templates
git config --global branch.autosetupmerge true
git config --global merge.tool opendiff
git config --global difftool.prompt false
git config --global mergetool.prompt false
git config --global push.default simple
git config --global color.ui auto


###########################################################
# Node
###########################################################

# Install latest version of Node with previously installed NVM
echo "Installing Node Version Manager..."
brew install nvm
# nvm install stable
# nvm use stable
nvm install 4.2
nvm alias default 4.2
nvm use 4.2

### Install NPM Packages
echo "Installing NPM packages..."
npm install -g bower                            # bower package manager
npm install -g browser-sync                     # time-saving synchronised browser testing
npm install -g grunt-cli                        # grunt task runner
npm install -g gulp                             # gulp task runner
npm install -g is-up                            # check if a site is up
npm install -g pageres                          # capture screenshots of websites in various resolutions
npm install -g psi                              # pagespeed insights with reporting
npm install -g svgo                             # svg optimizer
npm install -g tmi                              # discover your image weight on the web
npm install -g trash-cli                        # safer version of "rm -rf"
npm install -g vtop                             # visual "top" for the terminal


###########################################################
# Ruby
###########################################################

# Install latest Ruby version
if test ! $(which rbenv); then
    echo "Installing latest version of Ruby..."
    brew install rbenv
    brew install ruby-build
    rbenv install 2.2.2
    rbenv global 2.2.2
fi

# Install Bundler
echo "Installing Bundler..."
gem install bundler

# Install Compass
echo "Installing Compass..."
gem install compass

# Install Capistrano
echo "Installing Capistrano..."
gem install capistrano

# Rehash rbenv
rbenv rehash


###########################################################
# Create Dropbox Symlinks
###########################################################

# Possibly store some of these in a .dotfiles Github repo?

# Bash Profile
# Alfred
# Atom
# Flycut
# iTerm2
# ~/.wp-cli
# ~/scripts
# Sublime Text - https://packagecontrol.io/docs/syncing


###########################################################
# Misc
###########################################################

# Install Sublime package control
# Install required Sublime packages
# Copy over Sublime settings and snippets
# Add Sublime alias
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl

# Download and activate themes (iTerm2, Sublime, etc...)

# Replace current application icons with cooler ones (~/Dropbox/Computer\ Resources/icons)

# Install IE images for VirtualBox - https://github.com/xdissent/ievms
# curl -s https://raw.githubusercontent.com/xdissent/ievms/master/ievms.sh | env IEVMS_VERSIONS="7 8 9 10 11" bash

# Set the computer hostname
sudo scutil --set HostName <new host name>
