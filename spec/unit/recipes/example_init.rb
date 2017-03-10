#
# Cookbook Name:: spring-boot-app
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'spring-boot::example_init' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu',
                                          version: '14.04',
                                          step_into: ['spring_boot_web_app'])
      runner.converge(described_recipe)
    end

    it 'creates the app users' do
      %w(bootapp another_bootapp_user).each do |user|
        expect(chef_run).to create_user(user)
      end
    end

    it 'creates the groups' do
      %w(bootapp another_bootapp_group).each do |group|
        expect(chef_run).to create_group(group)
      end
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
