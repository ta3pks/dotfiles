if test -z "$SSH_ENV"
    set -xg SSH_ENV /tmp/sshenv
end

if not __ssh_agent_is_started
    __ssh_agent_start
end
