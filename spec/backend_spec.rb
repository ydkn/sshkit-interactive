describe SSHKit::Interactive::Backend do
  describe '#execute' do
    let(:host) { SSHKit::Host.new('example.com') }
    let(:backend) { SSHKit::Interactive::Backend.new(host) }

    it "does a system call with the SSH command" do
      expect_system_call('ssh -A -t example.com "/usr/bin/env ls"')
      backend.execute('ls')
    end

    it "respects the specified directory" do
      backend.within('/var/log') do
        expect_system_call('ssh -A -t example.com "cd /var/log && /usr/bin/env ls"')
        backend.execute('ls')
      end
    end

    it "respects the specified user" do
      backend.as('deployer') do
        expect_system_call('ssh -A -t example.com "sudo -u deployer && /usr/bin/env ls"')
        backend.execute('ls')
      end
    end

    it "respects the specified group" do
      backend.as(user: :user, group: :group) do
        expect_system_call('ssh -A -t example.com "sudo -u user && /usr/bin/env ls"')
        backend.execute('ls')
      end
    end

    it "respects the specified env"
  end
end
