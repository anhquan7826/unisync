import 'dart:io';
import 'dart:convert';

void main() async {
  // Replace with your server's IP address and port
  final serverAddress = 'localhost';
  final serverPort = 50112;

  // Create a socket connection
  final socket = await Socket.connect(serverAddress, serverPort);

  // Print a message to the console
  print('Connected to $serverAddress:$serverPort');

  // Start listening for console input
  stdout.write('> ');
  stdin.listen((data) {
    // Send the input to the socket
    socket
      ..writeln(utf8.decode(data))
      ..flush();

    // Print a prompt for the next input
    stdout.write('> ');
  });

  // Continuously read data from the socket
  socket.listen((data) {
    // Decode the received data
    final message = utf8.decode(data);

    // Print the received message
    print('Received: $message');
  });
}
