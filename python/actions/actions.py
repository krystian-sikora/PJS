# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa-pro/concepts/custom-actions


# This is a simple example for a custom action which utters "Hello World!"

import json

from typing import Any, Text, Dict, List

from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher

class OpeningHours(Action):
    def name(self) -> Text:
        return "action_opening_hours"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        with open("data/config/opening_hours.json", "r") as f:
            opening_hours = json.load(f)["items"]

            chosen_day = tracker.get_slot("day")

            if chosen_day in opening_hours:
                opening_hours = opening_hours.get(chosen_day)
                if opening_hours['open'] == 0 and opening_hours['close'] == 0:
                    dispatcher.utter_message("We are closed on that day")
                elif opening_hours:
                    dispatcher.utter_message(f"We are open from {opening_hours['open']} to {opening_hours['close']}")
                else:
                    dispatcher.utter_message("We are closed on that day")
            else:
                dispatcher.utter_message("I'm sorry, I don't know the opening hours for that day")
            
            return []
    
class Menu(Action):
    def name(self) -> Text:
        return "action_ask_menu_item"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        with open("data/config/menu.json", "r") as f:
            menu = {item["name"].lower(): item for item in json.load(f)["items"]}

            chosen_item = tracker.get_slot("item")

            if chosen_item in menu:
                item = menu.get(chosen_item)
                dispatcher.utter_message(f"{item['name']} costs {item['price']}$ and the preparation time is {item['preparation_time']}h")
            else:
                dispatcher.utter_message(f"I'm sorry, we don't have {chosen_item} in our menu")
            
            return []
        
class Order(Action):
    def name(self) -> Text:
        return "action_order"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        with open("data/config/menu.json", "r") as f:
            menu = {item["name"].lower(): item for item in json.load(f)["items"]}

            chosen_item = tracker.get_slot("item")

            if chosen_item in menu:
                item = menu.get(chosen_item)
                dispatcher.utter_message(f"Your order for {item['name']} has been placed. It will be ready in {60 * item['preparation_time']} minutes")
            else:
                dispatcher.utter_message(f"I'm sorry, we don't have {chosen_item} in our menu. Is there anything else you would like to order?")
            
            return []