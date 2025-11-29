run(){
    zig build || return false
    ./zig-out/bin/wcnt $1 $2 $3 $4 $5
}