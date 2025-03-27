opt server_output = "../build/server.luau"
opt client_output = "../build/client.luau"

event Dungeon = {
    from: Client,
    type: Reliable,
    call: ManyAsync,
    data: (to_place: boolean)
}

event Teleported = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: (destination: CFrame)
}