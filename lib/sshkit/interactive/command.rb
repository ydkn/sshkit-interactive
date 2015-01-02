module SSHKit
  module Interactive
    class Command
      attr_reader :host, :remote_command

      # remote_command can be an SSHKit::Command or a String
      def initialize(host, remote_command=nil)
        @host = host
        @remote_command = remote_command
      end

      # description:
      # http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
      def netssh_options
        self.host.netssh_options
      end

      def user
        self.host.user
      end

      def hostname
        self.host.hostname
      end

      def forward_agent?
        !!self.netssh_options[:forward_agent]
      end

      def keys
        self.netssh_options[:keys] || []
      end

      def auth_methods
        self.netssh_options[:auth_methods]
      end

      def auth_methods_str
        self.auth_methods.join(',')
      end

      def proxy
        self.netssh_options[:proxy]
      end

      def proxy_command
        self.proxy.command_line_template
      end

      def port
        self.netssh_options[:port]
      end

      def options
        opts = []
        opts << '-A' if self.forward_agent?
        self.keys.each do |key|
          opts << "-i #{key}"
        end
        opts << "-l #{self.user}" if self.user
        opts << %{-o "PreferredAuthentications #{self.auth_methods_str}"} if self.auth_methods
        opts << %{-o "ProxyCommand #{self.proxy_command}"} if self.proxy
        opts << "-p #{self.port}" if self.port
        opts << '-t' if self.remote_command

        opts
      end

      def options_str
        self.options.join(' ')
      end

      def path
        if self.remote_command.is_a?(SSHKit::Command)
          self.remote_command.options[:in]
        else
          nil
        end
      end

      def cd_command
        if self.path
          "cd #{self.path}"
        else
          nil
        end
      end

      def remote_commands
        [
          self.cd_command,
          self.remote_command
        ].compact
      end

      def remote_commands_str
        cmd = self.remote_commands.join(' && ')
        if cmd.empty?
          ''
        else
          %{"#{cmd}"}
        end
      end

      def to_s
        [
          'ssh',
          self.options_str,
          self.hostname,
          self.remote_commands_str
        ].reject(&:empty?).join(' ')
      end

      def execute
        system(self.to_s)
      end
    end
  end
end
