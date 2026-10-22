#####################################################################
#
# A Docker image to convert audio and video for web using web API
#
#   with
#     - FFMPEG (built)
#     - NodeJS
#     - fluent-ffmpeg
#
#   For more on Fluent-FFMPEG, see 
#
#            https://github.com/fluent-ffmpeg/node-fluent-ffmpeg
#
# Original image and FFMPEG API by Paul Visco
# https://github.com/surebert/docker-ffmpeg-service
#
#####################################################################

FROM node:lts-alpine@sha256:06d7adf3e0ef61a13f1d28682726366f97a15aa1888c934d3ecec86c33918b53 as build

RUN apk add --no-cache git

# install pkg
RUN npm install -g @yao-pkg/pkg

ENV PKG_CACHE_PATH /usr/cache

WORKDIR /usr/src/app

# Bundle app source
COPY ./src .
RUN npm ci --omit=dev

# Create single binary file
RUN pkg --targets node24-alpine-arm64 /usr/src/app/package.json


FROM jrottenberg/ffmpeg:8-alpine@sha256:3ab1c371ad3e734e7a31a3219e6a75120f1106c776b291db1bfc2d20158cd73e
# Create user and change workdir
RUN adduser --disabled-password --home /home/ffmpgapi ffmpgapi
WORKDIR /home/ffmpgapi

# Copy files from build stage
COPY --from=build /usr/src/app/ffmpegapi .
COPY --from=build /usr/src/app/index.md .
RUN chown ffmpgapi:ffmpgapi * && chmod 755 ffmpegapi

EXPOSE 3000

# Change user
USER ffmpgapi

ENTRYPOINT []
CMD [ "./ffmpegapi" ]

