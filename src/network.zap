opt server_output = "../build/server_network.luau"
opt client_output = "../build/client_network.luau"

event Dungeon = {
    from: Client,
    type: Reliable,
    call: ManyAsync,
    data: (toPlace: boolean, seed: string?)
}

event Teleported = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: (destination: CFrame)
}