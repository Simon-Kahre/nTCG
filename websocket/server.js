const Websocket = require("ws");

const server = new Websocket.Server({ port: 8080});

const roomCodes = [];

server.on("connection", (socket) => {
    console.log("A client connected!");
    

    socket.on("message", (message) => {
        if(message.toString().localeCompare("host") == 0)
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
        }
        console.log("Recieved:", message.toString());
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