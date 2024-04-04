# Defined in /tmp/fish.QZCPcl/pack.ssh_folder.fish @ line 2
function pack.ssh_folder
	mkdir -p /tmp/ssh_pack/out
	pushd /tmp/ssh_pack
	tar -czvf ssh.tar.gz ~/.ssh/
	gpg -ser nikos@mugsoft.io -o out/ssh.gpg ssh.tar.gz 
	rm -v ssh.tar.gz
	cp -v ~/.ssh/gpg_secret_key.asc ./out/
	tar -cvzf ssh.tar.gz out
	gpg -c -o q ssh.tar.gz 
	rm -vr ssh.tar.gz out
end
