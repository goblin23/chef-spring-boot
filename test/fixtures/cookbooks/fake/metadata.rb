name                    'fake'
maintainer              'The Authors'
maintainer_email        'you@example.com'
license                 'Apache License, Version 2.0'
description             'Installs/Configures spring-boot-app'
long_description        'Installs/Configures spring-boot-app'
source_url              'https://github.com/EtienneK/chef-spring-boot' if respond_to?(:source_url)
issues_url              'https://github.com/EtienneK/chef-spring-boot/issues' if respond_to?(:issues_url)
chef_version            '>= 12.1' if respond_to?(:chef_version)
supports                'centos'
version                 '0.0.1'

depends 'spring-boot'
depends 'java'
