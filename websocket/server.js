const Websocket = require("ws");

const server = new Websocket.Server({ port: 8080});

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
        //console.log("Recieved:", message.toString());
        console.log(users);
    };

    socket.on("close", () => {
        console.log("Client disconnected");
        delete users[socket.username];
        console.log(users);
    });
});

console.log("Server listening on ws://localhost:8080");

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