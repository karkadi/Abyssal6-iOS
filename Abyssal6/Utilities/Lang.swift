//
//  Lang.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
// Loads localization strings from a .strings file (or falls back to the built-in
// English table below).  The active language is stored in UserDefaults.
import Foundation

// MARK: – Lang

final class Lang {

    // MARK: Supported Languages

    enum Language: String, CaseIterable {
        case english = "en"
        case french  = "fr"
        case german  = "de"

        var displayName: String {
            switch self {
            case .english: return "English"
            case .french:  return "Français"
            case .german:  return "Deutsch"
            }
        }
    }

    // MARK: Singleton State

    static var current: Language = .english {
        didSet { UserDefaults.standard.set(current.rawValue, forKey: "lang") }
    }

    /// Load persisted language preference.
    static func loadPreference() {
        if let code = UserDefaults.standard.string(forKey: "lang"),
           let lang = Language(rawValue: code) {
            current = lang
        }
    }

    // MARK: Public API

    static func string(_ key: String) -> String {
        // 1. Try Localizable.strings for the current language bundle
        if let path = Bundle.main.path(forResource: "Localizable",
                                       ofType: "strings",
                                       inDirectory: nil,
                                       forLocalization: current.rawValue),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String],
           let value = dict[key] {
            return value.replacingOccurrences(of: "\\n", with: "\n")
        }
        // 2. Fall back to built-in English table
        return builtIn[key] ?? key
    }

    // MARK: – Built-in English Fallback Table
    // (Mirrors msg.txt; additional languages load from Localizable.strings)

    static let builtIn: [String: String] = [
        // Main messages
        "welcome": "--- SYSTEM ALERT: ABYSSAL-STATION-6 ---\nAn abyssal storm has damaged the structure.\nAs maintenance engineer your mission is vital:\nStabilize the reactor before the pressure crushes us!\n\nType 'help' if you need assistance.",
        "win": "******************************************\n       YOUR MISSION IS SUCCESSFUL!\n******************************************\nThanks to your speed the station is out of danger.\nThe reactor glows with a steady blue light.\nYou win!",
        "help": "You are alone in the deep...\nYou must explore the station to find the repair tools.\n\nYour commands are:",
        "end_game": "Thanks for playing.\nGoodbye.\n",

        // Rooms (long)
        "room_sas": "You are in the secure entry airlock.",
        "room_posteGarde": "You are in the armoured guard post.",
        "room_serre": "You are in the hydroponic greenhouse (the air is humid).",
        "room_labo": "You are in the flooded laboratory. The water is rising!",
        "room_infirmerie": "You are in the sterile infirmary.",
        "room_machines": "You are in the noisy engine room.",
        "room_reacteur": "You stand before the fusion reactor.\nThis is where everything happens!",
        "room_obs": "You are on the observation deck.\nThick armoured glass reveals the crushing blackness of the ocean.",
        "room_dortoir": "You are in the crew quarters.\nBeds are overturned and personal effects float in cold water.",
        "room_hydro": "You are in the hydroponics bay.\nStrange bioluminescent plants pulse with an eerie blue light.",
        "room_eng": "You are in the auxiliary engine room.\nThe floor vibrates heavily; a steam pipe has burst.",
        "room_air": "You are in the outer airlock.\nA heavy steel door leads into the deep sea. You feel the roar of pressure.",
        "room_med": "You are in the medical bay.\nRows of empty glass cabinets and a flickering surgical lamp cast long shadows.",

        // Short room names
        "short_room_sas": "Entry Airlock",
        "short_room_posteGarde": "Guard Post",
        "short_room_serre": "Hydroponic Greenhouse",
        "short_room_labo": "Flooded Laboratory",
        "short_room_infirmerie": "Infirmary",
        "short_room_machines": "Engine Room",
        "short_room_reacteur": "Fusion Reactor",
        "short_room_obs": "Observation Deck",
        "short_room_dortoir": "Crew Quarters",
        "short_room_hydro": "Hydroponics Bay",
        "short_room_eng": "Auxiliary Engine Room",
        "short_room_air": "Outer Airlock",
        "short_room_med": "Medical Bay",

        // Errors
        "wrong_command": "I don't understand what you mean...",
        "no_door": "There is no door!",
        "back_start": "You are already back at the start, there is nowhere further to go back.",
        "where_to_go": "Where do you want to go?",
        "exits": "Exits:",
        "found_item": "Item found:\n",

        // Directions
        "north": "North", "south": "South", "east": "East",
        "west": "West", "up": "Up", "down": "Down",
        "quit": "Quit", "back": "Back",

        // Items
        "item_beamer": "Beamer",
        "item_blue_card": "Blue Magnetic Card",
        "item_diving_suit": "Diving Suit",
        "item_genetic": "Genetic Sample",
        "item_magic_cookie": "Super-strength Elixir",
        "item_oxygen": "Oxygen Tank",
        "item_red_card": "Red Magnetic Card",
        "item_firstaid": "First-Aid Kit",
        "item_torch": "Torch",
        "item_wrench": "Wrench",

        // Inventory
        "take_what": "What do you want to take?",
        "drop_what": "What do you want to drop?",
        "eat_error": "What do you want to eat?",
        "item_taken": "Item taken:",
        "item_dropped": "Item dropped:",
        "cannot_take": "Cannot take this item",
        "cannot_drop": "Cannot drop this item (not in inventory)",
        "inventory": "Inventory:",
        "inventory_empty": "Your inventory is empty.",
        "total_weight": "Total weight: %.1f/%.1f kg",
        "error_item_not_found": "Item not found",
        "error_item_not_pickable": "Item cannot be picked up",
        "error_too_heavy": "Maximum weight reached",
        "item_not_in_inventory": "This item is not in your inventory.",
        "weight_bonus": "(+ %.1f kg weight bonus)",
        "ate_magic_cookie": "✨ You ate the magic cookie! ✨",
        "weight_doubled": "Your carrying capacity has doubled:",
        "item_not_in_room": "This item is not in this room.",
        "cannot_eat": "You cannot eat that",

        // Language
        "lang_error_no_code": "Error: Please supply a language code (e.g. 'lang en')",
        "lang_error_invalid_code": "Error: Unsupported language code",
        "lang_changed": "Language successfully changed to",

        // GUI labels
        "gui_title": "Abyssal-6: Submarine Adventure",
        "gui_timer": "TIME:",
        "gui_room": "ROOM:",
        "gui_navigation": "NAVIGATION",
        "gui_actions": "ACTIONS",
        "gui_look": "LOOK",
        "gui_inv": "INV",
        "gui_back": "BACK",
        "gui_help": "HELP",
        "gui_quit": "QUIT",
        "gui_input": "INPUT",
        "gui_save": "SAVE",
        "gui_load": "LOAD",
        "gui_talk": "TALK",
        "gui_give": "GIVE",
        "error_image_not_found": "Image not found:",

        // Inventory popup
        "inventory_title": "Inventory",
        "close_tooltip": "Close (Esc)",
        "inspect": "Inspect",
        "take": "Take",
        "drop": "Drop",
        "use": "Use",
        "eat": "Eat",
        "close": "Close",
        "inventory_summary_format": "%d items – (%.1fkg / %.1fkg)",
        "weight_format": "%.1f/%.1f kg",
        "item_details_title": "Item Details",
        "item_details_format": "📦 %@\n\nWeight: %.1f kg\nPickable: %@\nType: %@\n",
        "item_weight": "📦 Weight:",
        "item_pickable": "Pickable:",
        "item_type": "Type:",
        "yes": "Yes", "no": "No",
        "error_loading_icon": "Error loading icon:",
        "no_item_selected": "No item selected",
        "warning": "Warning",
        "already_owned": "This item is already in your inventory",
        "no_actions": "No actions available",
        "cannot_use": "Cannot use this item",
        "cannot_pickup": "This item cannot be picked up",

        // Trap/Doors
        "trapdoor_warning": "⚠️ Warning: Some exits are one-way trap doors!",
        "back_trapdoor_blocked": "Cannot go back – the trap door has closed.",
        "door_locked": "🔒 Locked door – Requires: %@",
        "door_unlocked": "🔓 Unlocked door",
        "door_locked_message": "This door is locked.",
        "wrong_key": "This key does not fit this door.",
        "use_what": "What do you want to use?",
        "cannot_use_item": "You cannot use this item that way.",

        // Character
        "no_characters_here": "There's no one to talk to here.",
        "character_not_found": "Character '%@' not found.",
        "no_one_wants_item": "No one seems interested in this item.",
        "item_given": "You gave the item.",
        "character_enters": "%@ enters the room.",
        "character_leaves": "%@ leaves the room.",
        "character_description_format": "  %@ – %@",
        "character_greeting_format": "\n  ✦ %@",
        "character_speak_format": "%@ says: \"%@\"",
        "character_response_format": "%@ says: \"%@\"",
        "character_help_format": "%@ says: \"%@\"",
        "character_speak_no_greeting_format": "%@ looks at you silently.",
        "character_exchange_offer_format": "%@ says: \"%@\"",
        "moving_strategy_random": "(They seem to wander aimlessly)",
        "moving_strategy_path": "(They follow a regular path)",
        "moving_strategy_player": "(They watch you carefully)",
        "help_characters": "\n=== CHARACTERS ===",
        "help_talk": "talk [name] : Talk to a character",
        "help_give": "give <item> : Give an item to a character",

        // Exchange
        "exchange_success": "✅ Exchange successful: you give %@ and receive %@.",
        "exchange_failed": "❌ Exchange failed.",
        "exchange_cancelled": "Exchange cancelled – item too heavy.",
        "item_not_consumed": "The character looks at the item but doesn't take it.",
        "help_received": "%@ has given you valuable information.",

        // Player
        "player_name": "You",
        "player_description": "Maintenance engineer",
        "presences": "👥 Present:",

        // Talk/Give popups
        "talk_title": "Talk to Characters",
        "give_title": "Give an Item",
        "talk_button": "Talk",
        "give_button": "Give",
        "cancel": "Cancel",
        "no_character_selected": "Please select a character.",
        "info": "Information",
        "character_silent": "Looks at you silently...",
        "talk_hint": "💬 Use TALK to speak",

        // Quit / Save / Load
        "quit_confirm_title": "Confirmation",
        "quit_confirm_message": "Are you sure you want to quit the game?",
        "quit_cancelled": "Returning to adventure...",
        "save_success": "Game saved as",
        "load_loading": "Loading",
        "load_error_xml": "Error loading game",
        "load_success": "Game loaded from",
        "load_usage": "Usage: load <filename>",
        "load_ready": "Ready! You can continue your adventure.",
        "load_refresh": "Refreshing interface...",
        "save_cancelled": "Save cancelled",
        "save_error": "Error saving game",
        "save_prompt": "Enter a name for your save:",
        "save_title": "Save Game",

        // Puzzle
        "puzzle_title": "Reactor Control Panel",
        "puzzle_confirm_exit": "Do you really want to abandon the reactor repair?",
        "confirm": "Confirmation",
        "puzzle": "EMERGENCY: Reactor control panel requires 3.3V power supply. Available voltage sources: 9V and 1.5V. Calculate which resistors must be connected to produce 3.3V output. Activate the corresponding switches and press the red button. Incorrect voltage will cause reactor explosion!",

        // Victory / Game Over
        "victory_title": "🏆 Victory!",
        "victory_message": "Congratulations! You saved the station!\n\nDo you want to play again?",
        "game_over_title": "💀 GAME OVER",
        "game_over_message": "The reactor exploded... The station is lost.",
        "game_over_confirm": "Do you want to start a new game?",
        "new_game": "New Game",

        // Introduction
        "intro_title": "Abyssal-6 – Introduction",
        "start_game": "START MISSION",
        "quit_game": "Quit",
        "introduction": "SYSTEM LOG: ABYSSAL-6 RESEARCH STATION\nDATE: 31.12.2074  DEPTH: 1,000 METRES\nYou wake to the screaming, rhythmic sound of a proximity alarm. The air is saturated with the smell of ozone and burnt metal.\nYour memories are hazy... A structural tremor? An explosion? The computer's voice is cold and distorted:\n'CRITICAL FAILURE IN SECTOR 4.\nHULL INTEGRITY AT 14%.\nREACTOR OVERHEAT DETECTED.\nESTIMATION BEFORE EXPLOSION: 10 MINUTES.'\nYou are in the Entry Airlock. Through the reinforced quartz glass the abyss stares back at you—total, crushing darkness.\nYou have no crew. No radio contact. Just your suit and the sound of your own panicked breathing.\nFind the Reactor. Repair the core.\nOr join the cemetery at the bottom of the world.\n\nMISSION: REPAIR THE REACTOR BEFORE FINAL EXPLOSION.",

        // Easter egg
        "easter_egg_title": "🎁 Easter Egg",
        "easter_egg_torch_brandish": "🔦 You brandish the torch...",
        "easter_egg_light_beam": "✨ A beam of light cuts through the darkness...",
        "easter_egg_secret_message": "🎁 A secret message appears on the porthole!",
        "easter_egg_battery_powerful": "🔋 Battery: %d%% – Powerful",
        "easter_egg_battery_moderate": "🔋 Battery: %d%% – Moderate",
        "easter_egg_battery_low": "🔋 Battery: %d%% – Low",
        "easter_egg_battery_critical": "🔋 Battery: %d%% – Critical!",
        "easter_egg_torch_depleted": "🔋 The torch goes out... The image disappears into darkness.",
        "easter_egg_torch_depleted_title": "Torch Depleted",
        "easter_egg_battery_too_low": "🔋 The torch battery is too weak to reveal the secret...",
        "easter_egg_battery_level": "   Battery level: %d%%",
        "easter_egg_charge_needed": "   Find a way to recharge it or use another source of light.",

        // Beamer
        "no_beamer": "You don't have a beamer.",
        "beamer_not_charged": "The beamer is not charged.",
        "beamer_already_charged": "The beamer is already charged.",
        "beamer_error": "Beamer error.",
        "beamer_fired": "⚡ Beamer fired! You are teleported.",
        "beamer_charged": "Beamer charged. Memorised room:",

        // Misc
        "load_file_not_found": "Error: Save file not found",
        "door_locked_direction": "Door to the %@ is now locked.",
        "door_unlocked_direction": "Door to the %@ is now unlocked.",
        "no_compatible_door": "No compatible door found for this item.",

        // PERSONNAGES FIXES

        // Dr. Chen (Scientist) - Laboratoire
        "character_scientist": "Dr. Chen",
        "character_scientist_desc": "Chief scientist, reactor specialist",
        "character_scientist_greeting": "Hello... are you new here? Be careful with the reactor, it's unstable.",
        "character_scientist_exchange": "I can give you an oxygen tank in exchange for your beamer.",

        // Doctor Williams - MedBay
        "character_doctor": "Doctor Williams",
        "character_doctor_desc": "Ship's doctor, can heal injuries",
        "character_doctor_greeting": "Are you injured? Sit down, let me examine you.",
        "character_doctor_exchange": "I can give you a super-strength elixir in exchange for oxygen.",

        // Guard Thompson - Poste de Garde
        "character_guard": "Guard Thompson",
        "character_guard_desc": "Security guard, protects sensitive areas",
        "character_guard_greeting": "HALT! Show me your papers... oh, a survivor. Sorry.",
        "character_guard_exchange": "I can give you a blue card in exchange for that torch.",

        // Engineer Martinez - Serre (Greenhouse)
        "character_engineer": "Engineer Martinez",
        "character_engineer_desc": "System engineer, knows the station like the back of his hand",
        "character_engineer_greeting": "Another survivor? The greenhouse is still holding... for now. The plants are our only source of oxygen.",
        "character_engineer_exchange": "I can give you a diving suit in exchange for that genetic sample. I need to study those deep-sea organisms.",

        // Nurse - Infirmerie
        "character_nurse": "Nurse",
        "character_nurse_desc": "A nurse making their rounds",
        "character_nurse_greeting": "Hello! Do you need care? I'm doing my rounds of the injured.",
        "character_nurse_exchange": "I can give you a first aid kit in exchange for that blue card. It might save your life down there.",

        // Dr. Aris Thorne (Geneticist) - Hydroponics
        "character_geneticist": "Dr. Aris Thorne",
        "character_geneticist_desc": "Chief geneticist, specialist in abyssal mutations",
        "character_geneticist_greeting": "Fascinating... the hydroponic plants are showing strange mutations from the deep-sea pressure. Have you seen anything interesting?",
        "character_geneticist_exchange": "I can give you a red card in exchange for that first aid kit. The medical supplies are critical for my research.",

        // PERSONNAGES MOBILES

        // Wandering Technician - Salle des machines
        "character_wandering_tech": "Wandering Technician",
        "character_wandering_tech_desc": "A technician wandering the station without apparent purpose",
        "character_wandering_tech_greeting": "*mumbles* ...too much work... not enough time... the reactor... must fix...",
        "character_wandering_tech_wrench": "My wrench! Finally! I can repair the circuits now.",

        // Researcher - Mobile character following a path
        "character_researcher": "Researcher",
        "character_researcher_desc": "A scientist doing their inspection rounds",
        "character_researcher_greeting": "I'm checking radiation levels along my route... everything seems stable for now. Keep moving, survivor.",

        // Shadow - Dortoir
        "character_stalker": "Shadow",
        "character_stalker_desc": "A silhouette that seems to follow you",
        "character_stalker_greeting": "... (they say nothing, but you feel their gaze)"
    ]
}
