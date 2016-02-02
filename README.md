# Jekbox

Jekbox uses Dropbox and Jekyll to automatically create and serve sites based on folders in your
Dropbox. Any folder with the `_jekbox.yml` will be treated as a Jekox site. Jekbox will server as many sites as there
are folders with a `_jekbox.yml` file.

One benefit of hosting sites from your Dropbox folder is that you can share the folders with other
people. So, if you're making a website for a friend or a client, they can edit they're site simply
by changing files in their personal Dropbox folder.

## Installation
`docker pull tombh/jekbox`

##Usage
```bash
  docker run \
    --restart always \
    --publish 80:80
    --volume $HOME/.jekbox/Dropbox:/root/Dropbox \
    --volume $HOME/.jekbox/.dropbox:/root/.dropbox \
    --name jekbox \
    tombh/jekbox`
```

On first installation you will be asked to connect your Dropbox account. Watch the logs for the
link to connect your account to Jekbox.

You will also need to make sure that the DNS for your site, eg `www.nicesite.com` points to the
server on which Jekbox is installed. You will do this from the admin interface of your domain registrar.

##TODO
  * Jexbox does not currently support wildcard domains, eg; `*.nicesite.com`. Let\'s use the `_jekbox.yml` file to specify
    which site answers to which domains.
  * Provide means to redirect 'www' to apex and vice-versa.
