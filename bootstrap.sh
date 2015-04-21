#!/usr/bin/env bash

# stops the execution of a script if a command or pipeline has an error
set -e

# check if provisioning script exists, if so, skip everything.
if [ ! -f /home/vagrant/.provisioning-progress ]; then
  su vagrant -c "touch /home/vagrant/.provisioning-progress"
  echo "-> file created in /home/vagrant/.provision-progress"
  apt-get update
else
  echo "-> file exists in /home/vagrant/.provisioning-progress"
fi

# set system locale
if grep -q +locale .provisioning-progress; then
  echo "-> locale already set"
else
  echo "-> setting locale"
  echo "LC_ALL=\"en_US.UTF-8\"" >> /etc/default/locale
  locale-gen en_US.UTF-8
  update-locale LANG=en_US.UTF-8
  su vagrant -c "echo +locale >> /home/vagrant/.provisioning-progress"
  echo "-> locale set"
fi

#Install Git, Build-essential, curl, vim, htop
if grep -q +core-libs .provisioning-progress; then
  echo "-> core libs already installed"
else
  echo "-> installing core libs (git, curl, etc)"
  apt-get update
  apt-get -y install build-essential curl git-core python-software-properties htop vim
  apt-get -y install nodejs # needed by Rails to have a Javascript runtime
  apt-get -y install zlib1g-dev libssl-dev libreadline6-dev libyaml-dev libncurses5-dev libxml2-dev libxslt-dev
  su vagrant -c "echo +core-libs >> /home/vagrant/.provisioning-progress"
  echo "-> core libs installed."
fi

# Default folder to /vagrant
if grep -q +default/vagrant .provisioning-progress; then
  echo "-> default/vagrant already configured"
else
  echo "-> configuring default /vagrant"
  sudo -u vagrant printf 'cd /vagrant\n' >> /home/vagrant/.profile
  su vagrant -c "echo +default/vagrant >> /home/vagrant/.provisioning-progress"
  echo "-> default/vagrant is now configured."
fi

# Install ruby
if grep -q +ruby/2.1.5 .provisioning-progress; then
  echo "-> ruby-2.1.5 is installed"
else
  echo "-> installing ruby-2.1.5"
  su vagrant -c "mkdir -p /home/vagrant/downloads; cd /home/vagrant/downloads; \
                 wget --no-check-certificate https://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz; \
                 tar -xvf ruby-2.1.5.tar.gz; cd ruby-2.1.5; \
                 mkdir -p /home/vagrant/ruby; \
                 ./configure --prefix=/home/vagrant/ruby --disable-install-doc; \
                 make; make install;"
  sudo -u vagrant printf 'export PATH=/home/vagrant/ruby/bin:$PATH\n' >> /home/vagrant/.profile

  su vagrant -c "echo +ruby/2.1.5 >> /home/vagrant/.provisioning-progress"
  echo "-> ruby-2.1.5 installed."
fi

# Install bundler
if grep -q +bundler .provisioning-progress; then
  echo "-> bundler already installed"
else
  echo "-> installing bundler"
  su vagrant -c "/home/vagrant/ruby/bin/gem install bundler --no-ri --no-rdoc"
  su vagrant -c "echo +bundler >> /home/vagrant/.provisioning-progress"
  echo "-> +bundler installed."
fi

# Install sqlite
if grep -q +sqlite .provisioning-progress; then
  echo "-> sqlite already installed"
else
  echo "-> installing sqlite"
  apt-get -y install libsqlite3-dev
  su vagrant -c "echo +sqlite >> /home/vagrant/.provisioning-progress"
  echo "-> +sqlite is now installed."
fi

# Run bundle install in the project
if grep -q +rails_app/bundle_install .provisioning-progress; then
  echo "-> bundle_install already ran"
else
  echo "-> bundle install in the project"
  su vagrant -c "export PATH=/home/vagrant/ruby/bin:$PATH; cd /vagrant; bundle;"
  su vagrant -c "echo +rails_app/bundle_install >> /home/vagrant/.provisioning-progress"
  echo "-> bundle install finished."
fi

#Install rails version 4.2.0
if grep -q +rails .provisioning-progress; then
  echo "-> rails 4.2.0 already setup"
else
  echo "-> setup rails 4.2.0"
  gem install rails -v 4.2.0
  su vagrant -c "echo +rails >> /home/vagrant/.provisioning-progress"
  echo "-> +rails finished."
fi

echo "All done"