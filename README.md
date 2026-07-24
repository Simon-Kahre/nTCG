# nTCG
nØllans Trading Card Game

To build and run the docker run in order:
`docker compose build --no-cache`
Then:
`docker compose up --force-recreate`

To rebuild the docker after making change to the game run:
`docker compose down`
Then:
`docker compose build --no-cache game`
Then:
`docker compose up --force-recreate`