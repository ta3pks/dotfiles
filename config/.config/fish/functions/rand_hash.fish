function rand_hash
dd if=/dev/urandom bs=1 count=20 2>/dev/null| md5
end
