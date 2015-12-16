Purple Mobile App
===

## Customer App

### To transcompile CoffeeScript into the proper JS folders, you can use something like:

    coffee -o . -cwb src

To build the app for upload to PhoneGap Build service, you can use:

    sencha app build

### Build Process:

    1. Make changes
    2. Launch terminal and go to directory's root
    3. 'sencha app build' and press enter
    4. Go to /app/build/production
    5. Compress Purple folder
    6. Go to build.phonegap.com
    7. Click on Update code
    8. Drag compressed file into upload section
    9. Download new app version from QR code

### View the application in browser:

    1. Launch Chrome with disabled web security: 
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --disable-web-security --user-data-dir=/tmp/chrome2/
    2. Drag index-debug.html file from root directory of app into the URL bar

## Courier App

### Courier Account Creation
    1. Open phpmyadmin
    2. ebdb -> Tables -> users -> Search tab
    3. Perform search by email
    4. Set is_courier to 1 for user
    5. Copy user ID
    6. Switch to Tables -> couriers -> Insert tab
    7. Paste user ID into ID field
    8. Set active: 1, on_duty: 1, zones: 1,2,3,4

### Courier Environment Setup
    1. Go to config.xml
    2. Comment out customer app only sections and uncomment courier app only sections
    3. Go to Main.coffee
    4. Comment out lines 95-108