// import * as admin from "firebase-admin";
const functions = require('firebase-functions');
// const admin = require('firebase-admin');



// import { StreamChat } from "stream-chat";

// admin.initializeApp();
// const serverClient = StreamChat.getInstance(
//     process.env.STREAM_API_KEY,
//     process.env.STREAM_API_SECRET,
// );



// Take the text parameter passed to this HTTP endpoint and insert it into 
// Firestore under the path /messages/:documentId/original
exports.testWebhook = functions.https.onRequest(async (req, res) => {
    let message = req.body.message;
    const formData = req.body.form_data || {};
    const action = formData["action"];

    functions.logger.log("custom log: on request");
    switch (action) {
        case "create":
            functions.logger.log("custom log: create", message.attachments);

            message.type = "regular";
            let attachment = message.attachments[0];
            attachment.actions = null;
            message.attachments = [
                attachment
            ]
            break;
        case "play":
            functions.logger.log("custom log: play", message.attachments);

            message.type = "regular";
            message.text = ' ';
            message.attachments = [
                {
                    type: "quiz",
                    quiz_command: "game",
                    game_id: formData["game_id"],
                    quiz_id: formData["quiz_id"],
                    quiz_name: formData["quiz_name"],
                    quiz_questions_count: formData["quiz_questions_count"],
                }
            ];
            break;
        case "cancel":
            functions.logger.log("custom log: cancel");
            message = null
            break;
        default:
            // NO ACTION HAS BEEN GIVEN. READ USER COMMAND.
            let arguments = message.args.split(" ");
            functions.logger.log("arguments", arguments);

            if (arguments.length > 2 || arguments.length < 1) {
                functions.logger.log("length not correct");

                message.type = "error";
                message.text = 'incorrect arguments'
                break;
            }
            let command = arguments[0].toLowerCase();
            switch (command) {
                case 'create':
                    functions.logger.log("command create game");
                    message.type = 'ephemeral';
                    message.text = 'creating game';
                    message.attachments = [
                        {
                            type: "quiz",
                            quiz_command: command,
                            actions: [
                                {
                                    type: "button",
                                    name: "action",
                                    value: "create",
                                    text: "Create",
                                    style: "primary",
                                },
                                {
                                    type: "button",
                                    name: "action",
                                    value: "cancel",
                                    text: "Cancel",
                                    style: "default",
                                },
                            ],
                        }
                    ];
                    break;
                case 'play':
                    functions.logger.log("command play games");

                    message.type = 'ephemeral';
                    message.text = ' ';
                    message.attachments = [
                        {
                            type: "quiz",
                            quiz_command: command,
                            actions: [
                                {
                                    type: "button",
                                    name: "action",
                                    value: "play",
                                    text: "Play",
                                    style: "primary",
                                },
                                {
                                    type: "button",
                                    name: "action",
                                    value: "cancel",
                                    text: "Cancel",
                                    style: "default",
                                },
                            ],
                        }
                    ];
                    break;
                default:
                    functions.logger.log("command does not exists");
                    message.type = 'error';
                    message.text = 'command does not exist';
                    message.attachments = null;
                    break;
            }

            break;
    }

    sendMessage(res, message);
});

function sendMessage(res, message) {
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({ message }));
}