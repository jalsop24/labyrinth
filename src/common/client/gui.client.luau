local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Env = require(ReplicatedStorage.Env)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Network = require(ReplicatedStorage.Network)

type Fusion = typeof(Fusion)

local isStartPlace = game.PlaceId == tonumber(Env.START_PLACE_ID)

local player = Players.LocalPlayer

local rootScope = Fusion.scoped(Fusion)
local seed = Fusion.Value(rootScope, "4321")

local function Button(
	scope: Fusion.Scope<Fusion>,
	props: {
		Text: Fusion.UsedAs<string>,
		LayoutOrder: Fusion.UsedAs<number>,
		OnActivated: () -> nil,
	}
)
	return scope:New("TextButton")({
		Text = props.Text,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -5, 1, -5),
		BackgroundTransparency = 0,
		Size = UDim2.fromOffset(100, 45),
		LayoutOrder = props.LayoutOrder,
		[Fusion.OnEvent("Activated")] = props.OnActivated,
	})
end

local function Menu(scope: Fusion.Scope<Fusion>, props: { [typeof(Fusion.Children)]: Fusion.Child })
	return scope:New("Frame")({
		Name = "Menu",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -5, 1, -5),
		[Fusion.Children] = {
			scope:New("UIListLayout")({
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
			}),
			props[Fusion.Children],
		},
	})
end

local _screenGui = rootScope:New("ScreenGui")({
	Name = "MainScreen",
	ResetOnSpawn = false,
	Parent = player.PlayerGui,

	[Fusion.Children] = {
		Menu(rootScope, {
			[Fusion.Children] = {
				DungeonButton = Button(rootScope, {
					Text = "Go to dungeon",
					LayoutOrder = 1,
					OnActivated = function()
						if isStartPlace then
							Network.Dungeon.Fire(true, Fusion.peek(seed))
						else
							Network.Dungeon.Fire(false)
						end
					end,
				}),
				BackButton = Button(rootScope, {
					Text = "Go back home",
					LayoutOrder = 2,
					OnActivated = function()
						print("go back")
						Network.TeleportHome.Fire()
					end,
				}),
			},
		}),
	},
})
