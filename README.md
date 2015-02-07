# Jekbox

Jekbox uses Dropbox and Jekyll to automatically create and serve sites based on folders in your
Dropbox that are named using a domain name. For example, if you place a folder in your Dropbox
named `www.nicesite.com` then Jekbox will build the contents with Jekyll and respond to all
requests to the `www.nicesite.com` by serving the contents of that folder.

## Installation
`docker pull tombh/jekbox`

##Usage
`docker run --restart --rm tombh/jekbox`
