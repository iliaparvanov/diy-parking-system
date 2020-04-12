# diy-parking-system

# Compile steps
## Arduino
To run the sketch in /arduino, the NewPing library is necessary. It is available on bitbucket and the Arduino website (https://playground.arduino.cc/Code/NewPing/). After the library has been installed in the Arduino IDE, the code should compile without any errors.

## App
There is an APK provided for quick testing. To run the code on the device with hot reload, the Flutter SDK must be installed and setup with Android Studio. Detailed instructions for Windows: https://flutter.dev/docs/get-started/install/windows Next, Android Studio will prompt for the flutter_bluetooth_serial library to be installed. After that is done, the project can be run either in an emulator or on a device which has USB debugging turned on and has been connected ot the PC through USB.
