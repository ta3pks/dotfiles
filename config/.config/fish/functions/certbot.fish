function certbot --description 'alias certbot=certbot --logs-dir /opt/homebrew/var/log --config-dir /opt/homebrew/etc/ --work-dir /opt/homebrew//var/lib'
 command certbot --logs-dir /opt/homebrew/var/log --config-dir /opt/homebrew/etc/ --work-dir /opt/homebrew//var/lib --nginx-server-root $HOMEBREW_PREFIX/etc/nginx/ $argv; 
end
