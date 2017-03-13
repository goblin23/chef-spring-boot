Spring Boot Chef Cookbook - *Work in Progress*
=====
Chef cookbook to install and deploy Spring Boot
Applications. Currently only supports Spring Boot Web
Apps.

Also, will only work on systems with `systemd` (default)
or `init.d` (System V) based init systems.

For `init.d`, the Spring Boot App must be configured
to be [fully executable](http://docs.spring.io/spring-boot/docs/current/reference/html/deployment-install.html).
Log location can also not be set for `init.d` and all
console logs will be written to `/var/log/<appname>.log`

Usage
-----

This cookbook provides a [custom resource](https://docs.chef.io/custom_resources.html) named `spring_boot_web_app`.
To use it you have to include `depends 'spring-boot'` in your `metadata.rb`.
to create an `spring_boot_web_app` ressource you have to include the following code in your recipe:
```ruby
spring_boot_web_app 'name_of_webapp' do
  jar_remote_path 'http://example.com/path/to/your/jar/your_jar.jar'
end
```
### Actions
- `install` - installs spring_boot_web_app from `jar_remote_path` (default)
- `uninstall`- removes previosly installed spring_boot_web_app instances

### Properties
- `name` - the name of the web_app
- `user`  - the user that runs the webapp `default: 'bootapp'`
- `group` - the group the user who runs the web_app belongs to `default: 'bootapp'``
- `port` - the port that the web_app listens on `default: 8080`
- `jar_remote_path` - the location the jar_file is fetched from
- `java_opts` - the `JAVA_OPTS` the application is started with
- `boot_opts`,  the `BOOT_OPTS` the application is started with
- `properties`, a Hash that describes properties files
e.g.: `{ 'app_1_initd' => { 'a' => '5', 'b' => '10' }, 'other_properties' => { 'c' => '25'}}` would create two properties files:
`app_1_initd.properties`
```
a=5
b=10
```
and `other_properties.properties`
```
c=25
```
- `repo_user`,  String
- `repo_password`,  String
- `init_system`,  'systemd'
- `wait_for_http`,  default: true
- `wait_for_http_retries`,  default: 24
- `wait_for_http_retry_delay` default: 5


## Testing

### Prerequisites

Make sure you have the following installed on your local PC:

-	[ChefDK](https://downloads.chef.io/chef-dk/)
-	[Vagrant](https://www.vagrantup.com/downloads.html)
-	[VirtualBox](https://www.virtualbox.org/wiki/Downloads)

### Running Tests

Run the following command in the root directory of this project (directory where this README.md file is located):

	$ kitchen test
