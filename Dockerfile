ARG OS_BASE=alpine
ARG OS_VERSION=3.20

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:6.0-${OS_BASE}${OS_VERSION} AS base

COPY .nuget                           /LunaMultiplayer/.nuget
COPY LmpCommon/LmpCommon.shproj       /LunaMultiplayer/LmpCommon/LmpCommon.shproj
COPY Lidgren/Lidgren.shproj           /LunaMultiplayer/Lidgren/Lidgren.shproj
COPY LmpGlobal/LmpGlobal.shproj       /LunaMultiplayer/LmpGlobal/LmpGlobal.shproj
COPY Lidgren.Core/Lidgren.Core.csproj /LunaMultiplayer/Lidgren.Core/Lidgren.Core.csproj
COPY Lidgren.Net/Lidgren.Net.csproj   /LunaMultiplayer/Lidgren.Net/Lidgren.Net.csproj
COPY uhttpsharp/uhttpsharp.csproj     /LunaMultiplayer/uhttpsharp/uhttpsharp.csproj
COPY LmpUpdater/LmpUpdater.csproj     /LunaMultiplayer/LmpUpdater/LmpUpdater.csproj
COPY Server/Server.csproj             /LunaMultiplayer/Server/Server.csproj

ARG OS_BASE
ARG OS_VERSION
ARG TARGETARCH
ARG TARGETVARIANT
RUN export TARGET=$(echo ${TARGETARCH}${TARGETVARIANT} | sed -e 's/amd64/x64/' -e 's/armv8/arm64/' -e 's/armv7/arm/'); \
    cd /LunaMultiplayer/Server && \
    dotnet restore -r ${OS_BASE}.${OS_VERSION}-${TARGET}

COPY . /LunaMultiplayer

FROM base AS debug
WORKDIR /LunaMultiplayer/Server
ENV DOTNET_PerfMapEnabled=1
ENV COMPlus_PerfMapEnabled=1
CMD [ "/bin/ash" ]

FROM --platform=$BUILDPLATFORM base AS builder
WORKDIR /LunaMultiplayer/Server
ARG OS_BASE
ARG OS_VERSION
ARG TARGETARCH
ARG TARGETVARIANT
RUN export TARGET=$(echo ${TARGETARCH}${TARGETVARIANT} | sed -e 's/amd64/x64/' -e 's/armv8/arm64/' -e 's/armv7/arm/'); \
    dotnet publish -c Release -r ${OS_BASE}.${OS_VERSION}-${TARGET} -o Publish

FROM ${OS_BASE}:${OS_VERSION}
RUN apk add icu-libs libstdc++ libgcc
COPY --from=builder /LunaMultiplayer/Server/Publish/ /LMPServer/
EXPOSE 6702/udp 6702/tcp
VOLUME "/LMPServer/Config" "/LMPServer/Plugins" "/LMPServer/Universe" "/LMPServer/logs"
STOPSIGNAL SIGINT
WORKDIR /LMPServer
CMD ./Server
