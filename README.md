Purple Mobile App
===

## Customer App

### To transcompile CoffeeScript into the proper JS folders, you can use something like:

    coffee -o . -cwb src

To build the app for upload to PhoneGap Build service, you can use:

    sencha app build

Be sure to use Sencha Cmd v5.1.3.61 (not the latest version).

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

### Courier App Over-the-Air Updates
    1. Make changes
    2. 'sencha app build' in Terminal
    3. Go to https://console.aws.amazon.com/s3/home?region=us-west-2#&bucket=purpledelivery&prefix=
    4. Delete app.js and util.js in the purpledelivery bucket
    5. Click upload and drag in app/build/production/Purple/app.js and app/build/production/Purple/util.js
    6. Start Upload
    7. Check Properties -> Permissions for app.js and util.js and grant Everyone permissions to access
    8. Make sure the app.json in the Courier App PG build has the right endpoints: {"id":"7544df46-a391-4dd6-a064-0b829a6e1d5a","js":[{"path":"https://s3-us-west-1.amazonaws.com/purpledelivery/util.js","remote":"true","update":"full","version":"8a1715a1a45b1610d660ed12344772c23fcf7220"},{"path":"GALocalStorage.js","version":"0b406d13e1464ec49688da13ede3b00939cc561a"},{"path":"resources/json/vehicleList.js","version":"aae196b6f6c38d1c9859083db7e26e4d87fbfd27"},{"path":"https://s3-us-west-1.amazonaws.com/purpledelivery/app.js","remote":"true","update":"full","version":"768717d8c34536350aaea190c41e2bf1a4d9249d"}],"css":[{"path":"resources/css/app.css","update":"delta","version":"6d8e82258aacf301359cac0f3b7db6b6eff904f1"},{"path":"resources/css/screen.css","update":"delta","version":"a9b5c5a0e20f0540d73854244fe74cdb247ecfa6"}]}
    9. Close app and restart to see updated changes