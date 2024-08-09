#!/bin/sh

/app/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
/app/bin/tailscale up --authkey=${TAILSCALE_AUTHKEY} # --hostname=fly-app

export LIVEBOOK_IDENTITY_PROVIDER=tailscale:/var/run/tailscale/tailscaled.sock
export LIVEBOOK_IP=$(/app/bin/tailscale ip -1 | tr -d '\n')

/app/bin/server
