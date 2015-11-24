Purple Mobile App
===

To transcompile CoffeeScript into the proper JS folders, you can use something like:

    coffee -o . -cwb src

To build the app for upload to PhoneGap Build service, you can use:

    sencha app build

Build Process:

    1. Make changes
    2. Launch terminal and go to directory's root
    3. 'sencha app build' and press enter
    4. Go to /app/build/production
    5. Compress Purple folder
    6. Go to build.phonegap.com
    7. Click on Update code
    8. Drag compressed file into upload section
    9. Download new app version from QR code

View the application in browser:

    1. Launch Chrome with disabled web security: 
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --disable-web-security --user-data-dir=/tmp/chrome2/
    2. Drag index-debug.html file from root directory of app into the URL bar