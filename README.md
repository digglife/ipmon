# ipmon

Bash scripts for monitoring the public IP obtained from ISP and
bind a domain name with it.

## Purpose

Access home servers any time any where.

- Add download job.
- Share files stored in NAS with friends via HTTP or FTP.
- Host a light website.
- ...

## How to use

1. Register a CloudFlare account and update the nameservers for your domain to
 Cloudflare's nameservers.
 2. Replace the values in `config.example` with yours and rename it to `config`
 3. Create a cron job such as `*/30 * * * * /path/to/update_public_ip.sh`.

## Why not ppp ip-up scripts?

Because I don't have a *hackable* router...

The most efficient way is to use [ppp ip-up][1] of course.

If you have a hackable router (like with openwrt installed) configured to
obtain public IP via PPPOE, simply call CloudFlare API to update the ip
in a shell script and put it under `/etc/ppp/ip-up.d/`.

[1]: http://www.tldp.org/HOWTO/PPP-HOWTO/ip-up.html "the /etc/ppp/ip-up script"
