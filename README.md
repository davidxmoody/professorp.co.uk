## Introduction

This is the source code for the new version of the <http://www.professorp.co.uk/> website. That link still points to the old version but the new one should be up within a week or so. 

## Setup

1. Install [Node.js](http://nodejs.org/download/) and [npm](https://www.npmjs.org/) (if it didn't already come with your installation of Node.js)
2. Install [Ruby](http://rubyinstaller.org/) and Sass (`gem install sass`)
3. Install [Git](http://git-scm.com/downloads)
4. Clone this repo `git clone https://github.com/davidxmoody/professorp.co.uk`
5. `cd` into the project directory
6. Run `npm install`

## Making changes

1. Run `npm start` to start the development server
2. Make changes to the source files and view the website in your browser at `http://localhost:9778`
3. Use Git to commit changes

## Deployment

1. Create a file called `config.json` in the project directory with your FTP settings:

        {
          "user": "USERNAME",
          "pass": "PASSWORD"
        }

2. Run `npm run-script deploy`
