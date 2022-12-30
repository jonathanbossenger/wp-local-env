# wp-local-env
[Cross OS WordPress local development environment](https://jonathanbossenger.com/2022/05/25/configuring-ubuntu-in-multipass-for-local-web-development-on-a-macbook/)

**Table of Contents**

 - [Introduction](#introduction)
 - [Requirements](#requirements)
 - [Installation](#installation)
 - [Usage](#usage)
 - [Additional Software](#additional-software)
 - [Using Multipass](#using-multipass)

## Introduction

wp-local-env is a cross OS (macOS, Windows, Linux) local development environment for WordPress (or any other PHP, MySQL web application). It is built on top of [Multipass](https://www.docker.com/) for minimal overhead and the fastest possible boot time.

## Requirements

1. [Multipass](https://multipass.run/) - as this is built on top of Multipass, you will need to first install it for your operating system.

You can find the Multipass installation instructions [here](https://multipass.run/install).

> **Note** Multipass for Windows requires either Hyper-V enabled in the BIOS, or Virtualbox installed

2. [mkcert](https://github.com/FiloSottile/mkcert): mkcert is a simple tool for making locally-trusted development certificates which require no configuration.

You can find the mkcert installation instructions [here](https://github.com/FiloSottile/mkcert#installation)

### Recommended mkcert installation for MacOS

1. Install [Homebrew](https://brew.sh/)

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Install mkcert with Homebrew
```
brew install mkcert
brew install nss # if you use Firefox
```

Once mkcert is installed, run the following command to install the root certificate in your local keychain:

```
mkcert -install
```

### Recommended mkcert installation for Linux 

**_Note that these instructions are currently untested_**

1. Install certutil.

```
sudo apt install libnss3-tools
    -or-
sudo yum install nss-tools
    -or-
sudo pacman -S nss
    -or-
sudo zypper install mozilla-nss-tools
```

2. Install [Homebrew](https://brew.sh/)

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3. Install mkcert with Homebrew
```
brew install mkcert
brew install nss # if you use Firefox
```

Once mkcert is installed, run the following command to install the root certificate in your local keychain:

```
mkcert -install
```

### Recommended mkcert installation for Windows

**_Note that these instructions are currently untested_**

1. Install [PowerShell](https://docs.microsoft.com/powershell/) terminal.

2. Install [Chocolatey](https://docs.chocolatey.org/en-us/choco/setup#install-with-powershell.exe) package manager for Windows in Powershell

3. Install mkcert with Chocolatey

```
choco install mkcert
```

Once mkcert is installed, run the following command to install the root certificate in your local keychain:

```
mkcert -install
```

## Installation

### macOS/Linux

Once you have the [requirements](#Requirements) installed, you can install wp-local-env by running the following commands:

1. Download the installer script
- Mac:
```
curl -o- https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/macos/install.sh > wp_local_env_install.sh
```
- Linux:
```
curl -o- https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/linux/install.sh > wp_local_env_install.sh
```

2. Make the script executable
```
chmod +x wp_local_env_install.sh
```
3. Run the installer
```
./wp_local_env_install.sh
```

The installer will launch a new Multipass instance, install all the required software on the instance, create and mount a directory in your home directory called `wp-local-env`, create a `sites` and `ssl-certs` directories in the `wp-local-env` directory, and install the `sitesetup`, `sitedrop` and `sitehosts` scripts to your local machine.

### Windows

(Coming soon)

#### Installing the hosts record

Once the installer is complete, run the following command to add the initial hosts record to your system:

```
sudo sitehosts
```

This will add a record pointing to the wp-local-env instance and map it to the url `wp-local-env.test`. You can change this url to access the instance in your browser.

If everything worked, you should see the default Debian Apache2 page in your browser.

![Apache 2](assets/debian.png)

#### MySQL root password

The MySQL root password is `password`.

## Usage

### Authenticate the host machine

Since Multipass version 1.9, it is required to authenticate the host machine with the new multipass instance. To do this, first create a local Multipass passphrase:

```
multipass set local.passphrase
```

You will be asked to enter, and then confirm the passphrase.

Next, authenticate the host machine

```
multipass authenticate
```

You will also need to run this as the sudo user

```
sudo multipass authenticate
```

### Provisioning sites

wp-local-env uses the two scripts installed on your local machine to set up sites. 

 - sitesetup - set up a new site
 - sitedrop - destroy/drop a site

To use sitesetup, run it with sudo permissions, and pass it a slug for the new site:

```
sudo sitesetup mysite
```

The sitesetup script will create the required directory in the `wp-local-env/sites` directory, as well as the locally trusted SSL certificate. It will then run a `sitesetup` script on the Multipass instance, creating the necessary Apache vhosts file, enabling it, and creating the database. Finally, the process will create a record in your /etc/hosts file, pointing to the new site. This allows you to access the site from a browser using a local domain with a .test extension, for example:

```
https://mysite.test
```

To use sitedrop, run it with sudo permissions, and pass it a slug for the site to be deleted:

```
sudo sitedrop mysite
```

The sitedrop script will completely delete all directories, files, configuration, and database for the site. It will also remove the record from your /etc/hosts file.

### MySQL credentials

The MySQL database created for your site will have the same name as the slug provided.

If you use a hypenated slug (eg `wp-local-env`), the database name will be that slug, without the hyphens (eg `wplocalenv`). 

MySQL database names are truncated at 16 characters, so try not to create a site with a slug longer then 16 characters.

### PHP version

By default, all new sites will be running the latest version of PHP (currently 8.2). To use the last major version of PHP (currently 8.1), run the following command when setting up a new site:

```
sudo sitesetup mysite 8.1
```

Currently, only PHP 8.2, 8.1, 8.0 and 7.4 are supported. 

### Installing WordPress

Originally, it was intended that wp-local-env would not have a default way to install WordPress. However, it's something that will be included in a later version, once it works across all operating systems. In the meantime, install WordPress in the way you prefer. [Download](https://wordpress.org/download/) and extract the zip to the site directory, use [WP-CLI](https://developer.wordpress.org/cli/commands/core/download/), or whatever you want. 

## Additional Software

wp-local-env comes preinstalled with both the PhpMyAdmin database tool, and the MailHog email testing tool. You can access both tools by visiting the following urls:

 - PhpMyAdmin: https://wp-local-env.test/phpmyadmin
 - MailHog: https://wp-local-env.test:8025

You can also replace `wp-local-env.test` with the url of any site you have set up.

All emails sent from PHP based sites will be captured by MailHog and made available in the web interface.

## Using Multipass

Multipass has detailed documentation on how to use it, which can be found [here](https://multipass.run/docs). However, here are some common Multipass commands you might find useful:

- `multipass list`: list all Multipass instances.
- `multipass shell wp-local-env`: connect to the wp-local-env instance. This allows you SSH into your wp-local-env instance, and run any commands on the server.
- `multipass stop wp-local-env`: stop the wp-local-env instance.
- `multipass start wp-local-env`: start the wp-local-env instance.
