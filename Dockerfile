FROM mcr.microsoft.com/dotnet/aspnet:5.0-alpine

ARG LMP_VERSION=0.29.0
ARG LMP_FILENAME=LunaMultiplayer-Server-Debug.zip

ARG LMP_URL=https://github.com/LunaMultiplayer/LunaMultiplayer/releases/download/$LMP_VERSION/$LMP_FILENAME

RUN apk add icu-libs libstdc++ libgcc wget

RUN wget $LMP_URL && \
    unzip $LMP_FILENAME && \
    rm -rf $LMP_FILENAME LMP\ Readme.txt

EXPOSE 6702/udp 6702/tcp
VOLUME "/LMPServer/Config" "/LMPServer/Plugins" "/LMPServer/Universe" "/LMPServer/logs"
STOPSIGNAL sigint
WORKDIR /LMPServer
CMD ["dotnet", "Server.dll"]
