FROM nginx:alpine

COPY trading-card-game/exports/web/ /usr/share/nginx/html/

RUN mv /usr/share/nginx/html/tradingCardGame.html \
       /usr/share/nginx/html/index.html

RUN echo "NEW BUILD $(date)" > /usr/share/nginx/html/build.txt

EXPOSE 80