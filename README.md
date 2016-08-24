# Spring Boot Chef Cookbook - *Work in Progress*

Chef cookbook to install and deploy Spring Boot 
Applications. Currently only supports Spring Boot Web 
Apps. 

Also, will only work on systems with `systemd` (default) 
or `init.d` (System V) based init systems.

For `init.d`, the Spring Boot App must be configured
to be [fully executable](http://docs.spring.io/spring-boot/docs/current/reference/html/deployment-install.html).
Log location can also not be set for `init.d` and all
console logs will be written to `/var/log/<appname>.log`

## Testing

### Prerequisites

Make sure you have the following installed on your local PC:

-	[ChefDK](https://downloads.chef.io/chef-dk/)
-	[Vagrant](https://www.vagrantup.com/downloads.html)
-	[VirtualBox](https://www.virtualbox.org/wiki/Downloads)

### Running Tests

Run the following command in the root directory of this project (directory where this README.md file is located):

	$ kitchen test

