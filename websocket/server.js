const Websocket = require("ws");

const server = new Websocket.Server({ port: 8080});

const roomCodes = [];

const users = {};

server.on("connection", (socket) => {
    console.log("A client connected!");
    

    socket.onmessage = (event) => {
        var data = JSON.parse(event.data)

        socket.username = data.username;
        if(data.host == 1)
        {
            var roomCode = generateRoomCode();
            console.log(roomCode);

            while(roomCodes.includes(roomCode))
            {
                roomCode = generateRoomCode();
                console.log(roomCode);
            }
            roomCodes.push(roomCode);
            socket.send(roomCode);

            users[socket.username] = {
                roomCode: roomCode,
                host: data.host
            };
        }
        else
        {
            if(roomCodes.includes(data.roomCode))
            {
                users[socket.username] = {
                    roomCode: data.roomCode,
                    host: data.host
                };
                socket.send("Room Exists");
            }
            else
            {
                console.log("Room Code doesn't exist");
                socket.send("Room does not exist");
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