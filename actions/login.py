import logging
from typing import Dict, Text, List

from rasa_sdk import Tracker
from rasa_sdk.events import EventType, SlotSet
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk import Action

from aiohttp_requests import requests

from . import url, SLOT_STATE, SLOT_METADATA

logger = logging.getLogger(__name__)

class LoginAction(Action):
    def name(self) -> Text:
        return "action_login"

    async def run(
        self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict
    ) -> List[EventType]:
        session_id = tracker.sender_id
        response = await requests.post(url('/sessions'), json={
            "session_id": session_id,
            "phone": "123"
        })

        events = []

        result = await response.json()
        logger.debug(result)

        if SLOT_STATE in result and result[SLOT_STATE] is not None:
            events.append(SlotSet(SLOT_STATE, result[SLOT_STATE]))

        if SLOT_METADATA in result and result[SLOT_METADATA] is not None:
            events.append(SlotSet(SLOT_METADATA, result[SLOT_METADATA]))

        # dispatcher.utter_message(template="utter_thanks")
        # dispatcher.utter_message(template="utter_ask_appt_time")
        return events
