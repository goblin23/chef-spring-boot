def install_spring_boot_web_app(name)
  ChefSpec::Matchers::ResourceMatcher.new(:spring_boot_web_app, :install, name)
end

def uninstall_spring_boot_web_app(name)
  ChefSpec::Matchers::ResourceMatcher.new(:spring_boot_web_app, :uninstall, name)
end
