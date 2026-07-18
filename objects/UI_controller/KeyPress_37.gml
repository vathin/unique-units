Game.Player1 = new Player(O_Server._id, "host");
O_DeckManager.create_card_displays(O_Server._id, 0);
O_DeckManager.create_card_displays(O_Server._id, 1);
set_layer_visible_safe(InGame_layer, 1);
set_layer_visible_safe("MainMenu", 0);