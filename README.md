## Setup

1. Install Node.js
2. Install NPM
3. Install Git
4. `cd` into the project directory
5. Run `npm install`

# Making changes

1. Run `npm start` to start the development server
2. Make changes to the source files and view the website in your browser at `http://localhost:9778`
3. Commit changes with `git commit`

# Deployment

1. Create a file called `config.json` in the project directory with your FTP settings:

        {
          "user": "USERNAME",
          "pass": "PASSWORD"
        }

2. Run `npm run-script deploy`
