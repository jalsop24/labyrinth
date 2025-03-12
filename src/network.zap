opt server_output = "../build/server.luau"
opt client_output = "../build/client.luau"

event Dungeon = {
    from: Client,
    type: Reliable,
    call: ManyAsync,
    data: (foo: boolean)
}