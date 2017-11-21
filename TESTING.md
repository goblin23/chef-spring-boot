# Cookbook TESTING

This document describes the process for testing this cookbook using ChefDK.

## Installing dependencies

Cookbooks may require additional testing dependencies that do not ship with ChefDK directly. These can be installed into the ChefDK ruby environment with the following commands

Install dependencies:

```shell
chef exec bundle install
```

Update any installed dependencies to the latest versions:

```shell
chef exec bundle update
```

### Linting

Linting is done with Ruby specific code linting using cookstyle (<https://github.com/chef/cookstyle>). Cookstyle offers a tailored RuboCop configuration enabling / disabling rules to better meet the needs of cookbook authors. Cookstyle ensures that projects with multiple authors have consistent code styling.

### Syntax Checking

Syntax Checking is done with the Chef cookbook specific linting and syntax checks with Foodcritic (<http://www.foodcritic.io/>). Foodcritic tests for over 60 different cookbook conditions and helps authors avoid bad patterns in their cookbooks.

### unit stage

The unit stage runs unit testing with ChefSpec (<http://sethvargo.github.io/chefspec/>). ChefSpec is an extension of Rspec, specially formulated for testing Chef cookbooks. Chefspec compiles your cookbook code and converges the run in memory, without actually executing the changes. The user can write various assertions based on what they expect to have happened during the Chef run. Chefspec is very fast, and quick useful for testing complex logic as you can easily converge a cookbook many times in different ways.

## Integration Testing

Integration testing is performed by Test Kitchen. After a successful converge, tests are uploaded and ran out of band of Chef. Tests should be designed to ensure that a recipe has accomplished its goal.

## Integration Testing using Vagrant

Integration tests can be performed on a local workstation using Docker using the kitchen-dokken driver. To run tests against all available instances run:

```shell
chef exec kitchen test
```

To see a list of available test instances run:

```shell
chef exec kitchen list
```

To test specific instance run:

```shell
chef exec kitchen test INSTANCE_NAME
```
