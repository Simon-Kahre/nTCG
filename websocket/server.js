const sqlite3 = require("sqlite3");
const db = new sqlite3.Database("/database/fooAccounts.db");

const Websocket = require("ws");

const server = new Websocket.Server({ port: 3000});

const roomCodes = [];

const users = {};

server.on("connection", (socket) => {
    console.log("A client connected!");
    

    socket.onmessage = (event) => {
        var data = JSON.parse(event.data)

        if(data.username)
        {
            socket.username = data.username;
        }

        if(data.type == "createRoom")
        {
            var roomCode = generateRoomCode();
            console.log(roomCode);

            while(roomCodes.includes(roomCode))
            {
                roomCode = generateRoomCode();
                console.log(roomCode);
            }
            roomCodes.push(roomCode);
            socket.send(JSON.stringify({type: "roomCreated", code: roomCode}));

            users[socket.username] = {
                roomCode: roomCode,
                host: data.host,
                socket: socket
            };
        }
        else if(data.type == "joinRoom")
        {
            if(roomCodes.includes(data.roomCode))
            {
                users[socket.username] = {
                    roomCode: data.roomCode,
                    host: data.host,
                    socket: socket
                };
                socket.send(JSON.stringify({type: "roomJoined"}));

                var sender = users[socket.username];

                for(const username in users)
                {
                    var user = users[username];

                    if(user.roomCode == sender.roomCode && user.socket != socket)
                    {
                        user.socket.send(JSON.stringify({type: "clientJoined"}));
                    }
                }
            }
            else
            {
                console.log("Room Code doesn't exist");
                socket.send(JSON.stringify({type: "error"}));
            }
        }
        else if(data.type == "offer" || data.type == "answer" || data.type == "candidate")
        {
            var sender = users[socket.username];
            if(!sender)
            {
                return;
            }

            for(const username in users)
            {
                var user = users[username];

                if(user.roomCode == sender.roomCode && user.socket != socket)
                {
                    user.socket.send(JSON.stringify(data));
                }
            }
        }
        else if(data.type == "database")
        {
            db.all("SELECT cardId, cardCount FROM groupCards JOIN users ON groupCards.userGroup = users.userGroup WHERE users.userId = $username ;", 
                {$username: data.username}, (err, row) => 
                {
                    if (err) {
                        console.error(err);
                        return;
                    }
                    console.log(row);
                    socket.send(JSON.stringify(row));
                });
            
        }
        //console.log("Recieved:", message.toString());
        console.log(users);
    };

    socket.on("close", () => {
        console.log("Client disconnected");

        var sender = users[socket.username];
        for(const username in users)
        {
            var user = users[username];

            if(user.roomCode == sender.roomCode && user.socket != socket)
            {
                user.socket.send(JSON.stringify({type: "playerLeft"}));
            }
        }
        if(sender)
        {
            const index = roomCodes.indexOf(sender.roomCode);

            if(index != -1)
            {
                roomCodes.splice(index, 1);
            }

            delete users[socket.username];
            console.log(users);
        }
    });
});

console.log("Server listening on ws://localhost: 3000");

function generateRoomCode()
{
    var roomCode = [];
    for(let i = 0; i < 6; i++)
    {
        roomCode.push(Math.floor(Math.random() * 10));
    }

    var roomCode = roomCode.toString().replaceAll(",", "");
    return roomCode;
}