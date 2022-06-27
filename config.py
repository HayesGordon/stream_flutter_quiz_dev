from stream_chat import StreamChat

client = StreamChat(api_key="zgcaa47zh79p", api_secret="dx9efgddkf8pj4a7xk7fvendtjtn7hthck5m3h3u23zpakk426sb46xrqq9afvp5")

# client.create_command(dict(
#     name="quiz",
#     description="Create a new quiz",
#     args="[description]",
# ))


# client.create_channel_type({
#   "name": "quiz-channel-type",
#   "commands": ["quiz"]
# })

client.update_app_settings(custom_action_handler_url="https://us-central1-stream-quiz-app-dev.cloudfunctions.net/testWebhook?type={type}")