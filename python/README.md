# Python restaurant chat based on Rasa

## How to use:
1. run `pip install -r requirements.txt`
2. run `rasa train`
3. run `rasa run actions`
4. run `rasa shell`

## Connecting to slack:
Follow the instructions in the [Rasa documentation](https://rasa.com/docs/rasa/user-guide/connectors/slack/) to connect the bot to slack.

### How to run bot for slack:
* run `rasa run --connector slack`
* run `rasa run actions`
* run `ngrok http 5005`
* copy the https url and paste it in the slack app settings with "/webhooks/slack/webhook" at the end

### Example conversation:

![image](https://github.com/user-attachments/assets/397f0146-8f4f-498e-9471-522dad04db22)
