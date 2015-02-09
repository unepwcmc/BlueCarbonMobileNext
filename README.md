# Blue Carbon Mobile

A PhoneGap application to allow iPad validation of a Blue Carbon data
layer, off- or on-line.

# Development

The main app is a web application, which lives inside the www/ folder.
As we use Coffeescript and Sass, `gulp` is used for compilation. Run:

    npm install
    gulp

This will compile the source and assets, and watch them for further
changes.

The app is run using the Cordova command line tool:

    npm install -g cordova
    # cordova emulate ios --target="<device>"
    cordova emulate ios --target="iPad-Air"

# Debugging

Check out the Phonegap [debugging
guide](https://github.com/phonegap/phonegap/wiki/Debugging-in-PhoneGap)
for lots of info.

### Better remote console logging

Console logging is static and crazy unpredictable in phonegap by
default, so there is a hook that forces the application to wait for a
manual signal before it starts, thereby allowing better console logging.
To use, start the Blue Carbon app (in index.html) with the
'waitForRemoteConsole' set to true:

    window.blueCarbonApp = new BlueCarbon.App({waitForRemoteConsole: true});

Then, connect your remote web inspector console, and manually start the
app from the console:

    window.blueCarbonApp.start();

Enjoy proper console.logging.
