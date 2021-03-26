user 'vhserver' do
    manage_home true
end

remote_file '/home/vhserver/linuxgsm.sh' do
    source 'https://linuxgsm.sh'
    mode '0755'
    owner 'vhserver'
end

execute 'linuxgsm' do
    command './linuxgsm.sh vhserver'
    cwd '/home/vhserver'
    user 'vhserver'
    live_stream true
    not_if { ::File.exist?('/home/vhserver/vhserver') }
end

execute 'vhserver_install_dependencies' do
    command './vhserver auto-install'
    cwd '/home/vhserver'
    live_stream true
end

execute 'vhserver_install' do
    command './vhserver auto-install'
    cwd '/home/vhserver'
    user 'vhserver'
    environment ({'HOME' => '/home/vhserver'})
    live_stream true
end

execute 'vhserver_start' do
    command './vhserver start'
    cwd '/home/vhserver'
    user 'vhserver'
    environment ({'HOME' => '/home/vhserver'})
    live_stream true
end
