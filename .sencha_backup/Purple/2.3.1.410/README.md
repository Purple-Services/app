Purple Mobile App
===

To transcompile CoffeeScript into the proper JS folders, you can use something like:

    coffee -o . -cwb src

To build the app for upload to PhoneGap Build service, you can use:

    sencha app build package
