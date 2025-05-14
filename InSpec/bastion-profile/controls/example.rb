control 'packages-installed' do
  title 'Verificar que los paquetes están instalados'
  describe package('ufw') do
    it { should be_installed }
  end
  describe package('fail2ban') do
    it { should be_installed }
  end
  describe package('auditd') do
    it { should be_installed }
  end
end

control 'ssh-config' do
  title 'Comprobar configuración segura de SSH'
  describe sshd_config do
    its('PermitRootLogin') { should cmp 'no' }
    its('PasswordAuthentication') { should cmp 'no' }
    its('Port') { should cmp 22 }
  end
end

control 'puertos-inseguros' do
  title 'Verificar que puertos inseguros no están abiertos'
  describe port(23) do
    it { should_not be_listening }
  end
end

control 'servicios' do
  title 'Verificar servicios innecesarios'
  describe service('telnet') do
    it { should_not be_enabled }
    it { should_not be_running }
  end
end

control 'ufw-status' do
  title 'Verificar configuración del firewall'
  describe command('ufw status') do
    its('stdout') { should match /22.*ALLOW IN.*192\.168\.50\.101/ }
    its('stdout') { should_not match /ALLOW IN\s+Anywhere/ }
  end
end
