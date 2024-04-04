function paysy_ssh --wraps='pssh -h .ssh/paysy_proxy' --description 'alias paysy_ssh=pssh -h .ssh/paysy_proxy'
  pssh -p 16 -h $HOME/.ssh/paysy_proxy $argv; 
end
