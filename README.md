# Jekbox

Jekbox uses Dropbox and Jekyll to automatically create and serve sites based on folders in your
Dropbox that are named using a domain name. For example, if you place a folder in your Dropbox
named `www.nicesite.com` then Jekbox will build the contents with Jekyll and respond to all
requests to the `www.nicesite.com` by serving the contents of that folder.

## Installation
`docker pull tombh/jekbox`

##Usage
`docker run --restart always --publish 80:80 --name jekbox jekbox`

On first installation you will be asked to connect your Dropbox account. Watch the logs for the
link to connect your account to Jekbox.

You will also need to make sure that the DNS for your site, eg `www.nicesite.com` points to the
server on which Jekbox is installed.

Jexbox does not currently support wildcard domains, eg; `*.nicesite.com`.

##TODO
Instructions for using a data container to persist Dropbox setup. All it will mean is that you don't
have to link your account every time.
