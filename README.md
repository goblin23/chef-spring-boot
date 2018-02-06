[![Cookbook Version](https://img.shields.io/cookbook/v/spring-boot.svg)](https://supermarket.chef.io/cookbooks/spring-boot)
[![Build Status](https://travis-ci.org/goblin23/chef-spring-boot.svg?branch=master)](https://travis-ci.org/goblin23/chef-spring-boot)
=====================================================
Spring Boot Chef Cookbook
=====================================================
This Chef cookbook provides a [custom resource](https://docs.chef.io/custom_resources.html) **spring_boot_web_app** to install and deploy Spring Boot
Applications. Currently only supports Spring Boot Web
Apps.

Also, will only work on systems with `systemd` or `init.d` (System V) based init systems.

For `init.d`, the Spring Boot App must be configured
to be [fully executable](http://docs.spring.io/spring-boot/docs/current/reference/html/deployment-install.html).
Log location can also not be set for `init.d` and all
console logs will be written to `/var/log/<appname>.log`

This [custom resource](https://docs.chef.io/custom_resources.html) does not install java.
Java must be installed on the target node before using the [custom resource](https://docs.chef.io/custom_resources.html) **spring_boot_web_app**
To use it you have to include `depends 'spring-boot'` in your `metadata.rb`.

Syntax
=====================================================

This cookbook provides a [custom resource](https://docs.chef.io/custom_resources.html) named `spring_boot_web_app`.
The simplest use of the **spring_boot_web_app** resource is:
```
spring_boot_web_app 'name_of_webapp' do
  jar_remote_path 'http://example.com/path/to/your/jar/your_jar.jar'
end
```
which will download your artifact from **jar_remote_path** and create a "systemd" service listening on port ***8080***
started by the user ***bootapp***

The full syntax for all of the properties that are available to the **spring_boot_web_app** resource is:
```
spring_boot_web_app 'name_of_webapp' do
  notifies                   # see description
  user                       String # defaults to bootapp
  group                      String # defaults to bootapp
  port                       Integer # defaults to 8080
  jar_remote_path            String
  java_opts                  String
  boot_opts                  String
  properties                 Hash
  repo_user                  String
  repo_password              String
  init_system                String # defaults to systemd
  wait_for_http              [TrueClass, FalseClass] # defaults to true
  wait_for_http_retries      Integer # defaults 24
  wait_for_http_retry_delay  Integer # defaults 5
  subscribes                 # see description
  action                     Symbol # defaults to :install if not specified
end
```
where

* ``user``  - the user that runs the webapp `default: 'bootapp'`
* ``group`` - the group the user who runs the web_app belongs to `default: 'bootapp'``
* ``port`` - the port that the web_app listens on `default: 8080`
* ``jar_remote_path`` - the location the jar_file is fetched from
* ``java_opts`` - the `JAVA_OPTS` the application is started with
* ``boot_opts`` - the `BOOT_OPTS` the application is started with
* ``properties`` - a Hash that describes properties files
* ``repo_user`` - the user if your `jar_remote_path` is protected by basic auth
* ``repo_password`` - the password if your `jar_remote_path` is protected by basic auth
* ``init_system`` - for now `systemd` and `initd` are valid options `default: 'systemd'`
* ``wait_for_http`` - should chef wait for the webapp to answer `default: true`
* ``wait_for_http_retries`` - how many times should chef-client retry   `default: 24`
* ``wait_for_http_retry_delay`` - how long should chef-client wait before each request `default: 5`
* ``jmx_credentials`` - a hash that describes jmx_credentials

See "Properties" section below for more information about all of the properties that may be used with this resource.

Actions
=====================================================
This resource has the following actions:

``:install``
  Default. Installs spring_boot_web_app from `jar_remote_path`

``:uninstall``
  Removes previosly installed spring_boot_web_app instances

### Properties

``notifies``
   **Ruby Type:** Symbol, 'Chef::Resource[String]'

   A resource may notify another resource to take action when its state changes. Specify a ``'resource[name]'``, the ``:action`` that resource should take, and then the ``:timer`` for that action. A resource may notify more than one resource; use a ``notifies`` statement for each resource to be notified.

   A timer specifies the point during the chef-client run at which a notification is run. The following timers are available:

   ``:before``
      Specifies that the action on a notified resource should be run before processing the resource block in which the notification is located.

   ``:delayed``
      Default. Specifies that a notification should be queued up, and then executed at the very end of the chef-client run.

   ``:immediate``, ``:immediately``
      Specifies that a notification should be run immediately, per resource notified.

   The syntax for ``notifies`` is:

```
notifies :action, 'resource[name]', :timer
```

``properties``
   **Ruby Type:** Hash

   Optional. The keys on the toplevel of the hash are the filename of a properties file postfixed with **.properties**
   the values of the toplevel keys are hashes containing key, value pairs that are written out to the file - for example:
```
{ 'app_1_initd' => { 'a' => '5', 'b' => '10' }, 'other_properties' => { 'c' => '25'} } 
```
would create two properties files:

file                          | content       |
------------                  | ------------- |
`app_1_initd.properties`      | `a=5` `b=10`  |
`other_properties.properties` | `c=25`        |

``jmx_credentials``
   **Ruby Type:** Hash

  Optional. the keys on the toplevel are the usernames their values are hases containing a `password` and `access` key.
  - for example:
```
{ 'monitorRole' => { 'password' => 'monitor', 'access' => 'readonly'} }
```
would create the two files jmxremote.access and jmxremote.password as follows:
```
# jmxremote.access
monitorRole readonly

# jmxremote.password
monitorRole monitor
```
Examples
=====================================================

Examples can be found in test/fixtures/cookbooks/fake/recipes/
