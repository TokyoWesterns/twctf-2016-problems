package "psmisc"
package "lsof"

package "libapache2-mod-php5"

file '/etc/php5/apache2/conf.d/05-opcache.ini' do
  action :delete
end

file '/etc/php5/apache2/php.ini' do
  action :edit
  block do |content|
    content.gsub!(/disable_functions = .*/, 'disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,symlink,chgrp,chmod,chown,dl,mail,imap_mail,apache_child_terminate,posix_kill,proc_terminate,proc_get_status,syslog,openlog,ini_alter,ini_set,ini_restore,putenv,apache_setenv,pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,')
  end
end

service 'apache2' do
  action :restart
end
