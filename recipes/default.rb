user = node['valheim']['user']
home_dir = "/home/#{user}"
install_dir = node['valheim']['install_dir']
serverfiles_dir = "#{node['valheim']['install_dir']}/serverfiles"
vhserver_file = "#{node['valheim']['install_dir']}/vhserver"
server_config = node['valheim']['config']

user user do
    home home_dir
    manage_home true
end

remote_file "#{install_dir}/linuxgsm.sh" do
    source 'https://linuxgsm.sh'
    mode '0755'
    owner user
    action :create_if_missing
end

execute 'linuxgsm' do
    command './linuxgsm.sh vhserver'
    cwd install_dir
    user user
    live_stream true
    not_if { ::File.exist?(vhserver_file) }
end

execute 'vhserver_install_dependencies' do
    command './vhserver auto-install'
    cwd install_dir
    live_stream true
    not_if { ::Dir.exist?(serverfiles_dir) }
end

execute 'vhserver_install' do
    command './vhserver auto-install'
    cwd install_dir
    user user
    environment ({'HOME' => home_dir})
    live_stream true
    not_if { ::Dir.exist?(serverfiles_dir) }
end

template "#{install_dir}/lgsm/config-lgsm/vhserver/vhserver.cfg" do
    source 'vhserver.cfg.erb'
    owner user
    variables(
        :servername => server_config['servername'],
        :serverpassword => server_config['serverpassword'],
        :port => server_config['port'],
        :savedir => server_config['savedir']
    )
    notifies :restart, 'service[vhserver]', :delayed
end

directory server_config['savedir'] do
    owner user
end

template "/etc/systemd/system/vhserver.service" do
    source 'vhserver.service.erb'
    variables(
        :user => user,
        :install_dir => install_dir
    )
    notifies :restart, 'service[vhserver]', :delayed
end

service 'vhserver' do
    action [:enable, :start]
end
