
FROM node:7-alpine
# install node-gyp dependancies (for alpine only)
RUN apk add --update python make alpine-sdk libc6-compat

MAINTAINER altoros.com
LABEL com.altoros.version="0.1"
LABEL com.altoros.description="Fabric 1.0 rest api"

# Create app directory
WORKDIR /usr/src/app

COPY . .
RUN npm install

ENV PORT=8080
EXPOSE 8080

CMD [ "npm", "start" ]