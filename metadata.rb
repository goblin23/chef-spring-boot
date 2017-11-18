name 'spring-boot'
maintainer 'Guido Schöninig'
maintainer_email 'guido.schoening@gmail.com'
license 'Apache-2.0'
description 'Installs/Configures spring-boot-app'
long_description 'Installs/Configures spring-boot-app'
version '0.5.0'
chef_version '>= 12.5' if respond_to?(:chef_version)
supports 'ubuntu'
supports 'centos'

depends 'java'

source_url 'https://github.com/goblin23/chef-spring-boot' if respond_to?(:source_url)
issues_url 'https://github.com/goblin23/chef-spring-boot/issues' if respond_to?(:issues_url)
