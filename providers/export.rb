action :create do
  ruby_block "nfs_export_#{new_resource.directory.sub(/\//,'_')}" do
    not_if { node[:nfs][:exports].detect {|x| x.match "^#{new_resource.directory}" } }
    block do
      ro_rw = new_resource.writeable ? "rw" : "ro"
      sync_async = new_resource.sync ? "sync" : "async"
      extra_options = new_resource.extra_options.join(',')
      extra_options = ",#{extra_options}" unless extra_options == ""
      export = "#{new_resource.directory} #{new_resource.network}(#{ro_rw},#{sync_async}#{extra_options})"
      node[:nfs][:exports] << export
    end
    notifies :create, resources("template[/etc/exports]")
    new_resource.updated_by_last_action(true)
  end
end
