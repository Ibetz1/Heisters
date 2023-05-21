player_data = {
    cards = {
        {},
        {},
        {},
        {}
    },
    gems = 0,
    coins = 0,
    card_fragments = {},
    current_card = nil,
    skin = 1,
    level = 1,
    xp = 0,
}

function add_player_card(skin, rarity, perks)
    store_data_files()

    table.insert(player_data.cards[rarity], {
        skin = skin,
        perks = perks,
        rarity = rarity
    })
end

function set_player_card(card)
    player_data.current_card = player_data.cards[card]
    player_data.skin = player_data.cards[card].skin
end