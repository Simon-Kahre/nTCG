require("dotenv").config();

const { Pool } = require("pg");
const Websocket = require("ws");

const db = new Pool({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT),
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD
});

const server = new Websocket.Server({
    port: Number(process.env.SERVER_PORT)
});

const roomCodes = [];
const users = {};

server.on("connection", (socket) => {
    console.log("A client connected!");

    socket.onmessage = async (event) => {
        const data = JSON.parse(event.data);

        if (data.username) {
            socket.username = data.username;
        }

        if (data.type == "createRoom") {
            let roomCode = generateRoomCode();

            while (roomCodes.includes(roomCode)) {
                roomCode = generateRoomCode();
            }

            roomCodes.push(roomCode);

            socket.send(JSON.stringify({
                type: "roomCreated",
                code: roomCode
            }));

            users[socket.username] = {
                roomCode: roomCode,
                host: data.host,
                socket: socket
            };
        }

        else if (data.type == "joinRoom") {
            if (roomCodes.includes(data.roomCode)) {

                users[socket.username] = {
                    roomCode: data.roomCode,
                    host: data.host,
                    socket: socket
                };

                socket.send(JSON.stringify({
                    type: "roomJoined"
                }));

                const sender = users[socket.username];

                for (const username in users) {
                    const user = users[username];

                    if (user.roomCode == sender.roomCode && user.socket != socket) {
                        user.socket.send(JSON.stringify({
                            type: "clientJoined"
                        }));
                    }
                }

            } else {
                console.log("Room Code doesn't exist");

                socket.send(JSON.stringify({
                    type: "error"
                }));
            }
        }

        else if (
            data.type == "offer" ||
            data.type == "answer" ||
            data.type == "candidate"
        ) {

            const sender = users[socket.username];

            if (!sender) {
                return;
            }

            for (const username in users) {
                const user = users[username];

                if (user.roomCode == sender.roomCode && user.socket != socket) {
                    user.socket.send(JSON.stringify(data));
                }
            }
        }


        // Hämta data från PostgreSQL
        else if (data.type == "database") {

            try {
                const result = await db.query(
                    `
                    SELECT cardid, cardcount
                    FROM groupcards
                    JOIN users 
                    ON groupcards.usergroup = users.usergroup
                    WHERE users.userid = $1;
                    `,
                    [data.username]
                );

                console.log(result.rows);

                socket.send(JSON.stringify(result.rows));

            } catch (err) {
                console.error(err);
            }
        }


        // Uppdatera PostgreSQL
        else if (data.type == "manageData") {
            if (!socket.userID) {
                socket.send(JSON.stringify({
                    type: "databaseUpdated",
                    success: false,
                    message: "Not authenticated"
                }));
                return;
            }
            console.log("Changing Database");

            try {
                const result = await db.query(
                    `
                    SELECT usergroup
                    FROM users
                    WHERE users.userid = $1
                    `,
                    [
                        socket.userID
                    ]
                );

                if (result.rows.length === 0) {
                    socket.send(JSON.stringify({
                        type: "databaseUpdated",
                        success: false,
                        message: "User not found"
                    }));
                    return;
                }

                if (result.rows[0].usergroup !== "M") {
                    socket.send(JSON.stringify({
                        type: "databaseUpdated",
                        success: false,
                        message: "No permission"
                    }));
                    return;
                }

                try {

                    const check = await db.query(
                        `
                        SELECT cardcount
                        FROM groupcards
                        JOIN users 
                        ON groupcards.usergroup = users.usergroup
                        WHERE users.userid = $1
                        AND cardid = $2;
                        `,
                        [
                            data.username,
                            data.cardId
                        ]
                    );


                    if (check.rows.length > 0) {

                        console.log("Card existed");

                        const count =
                            check.rows[0].cardcount + Number(data.increase);


                        await db.query(
                            `
                            UPDATE groupcards
                            SET cardcount = $1
                            WHERE usergroup = (
                                SELECT usergroup
                                FROM users
                                WHERE userid = $2
                            )
                            AND cardid = $3;
                            `,
                            [
                                count,
                                data.username,
                                data.cardId
                            ]
                        );


                        socket.send(JSON.stringify({
                            type: "databaseUpdated",
                            success: true,
                            message: "Card count updated"
                        }));

                    }

                    else {

                        console.log("Card didn't exist");


                        await db.query(
                            `
                            INSERT INTO groupcards
                            (
                                usergroup,
                                cardid,
                                cardcount
                            )

                            SELECT 
                                usergroup,
                                $1,
                                $2

                            FROM users

                            WHERE userid = $3;
                            `,
                            [
                                data.cardId,
                                Number(data.increase),
                                data.username
                            ]
                        );


                        socket.send(JSON.stringify({
                            type: "databaseUpdated",
                            success: true,
                            message: "Card added"
                        }));
                    }


                } catch (err) {
                    console.error(err);
                }
            } catch (err) {
                console.error(err);
            }
        }

        else if (data.type == "authenticate") {


            const result = await db.query(
                `
                SELECT userid
                FROM users
                WHERE userid = $1
                `,
                [
                    data.user
                ]
            );

            if (result.rows.length === 0) {
                socket.close();
                return;
            }

            socket.userID = data.user;

            console.log("Authenticated:", socket.userID);

            return;

        }
    };


    socket.on("close", () => {

        console.log("Client disconnected");

        const sender = users[socket.username];

        if (!sender) {
            return;
        }


        for (const username in users) {

            const user = users[username];

            if (user.roomCode == sender.roomCode && user.socket != socket) {

                user.socket.send(JSON.stringify({
                    type: "playerLeft"
                }));
            }
        }


        const index = roomCodes.indexOf(sender.roomCode);

        if (index != -1) {
            roomCodes.splice(index, 1);
        }


        delete users[socket.username];

        console.log(users);
    });
});


console.log(
    `Server listening on ws://localhost:${process.env.SERVER_PORT}`
);



function generateRoomCode() {

    let roomCode = [];

    for (let i = 0; i < 6; i++) {
        roomCode.push(Math.floor(Math.random() * 10));
    }

    return roomCode.join("");
}