# TMQTTClient Library Version 1.01 for Delphi by Jamie I

## INTRODUCTION:
TMQTTClient is a non-visual Delphi Client Library for the IBM Websphere MQ Transport Telemetry protocol ( http://mqtt.org ). It allows you to connect to a Message Broker that uses MQTT such as the Really Small Message Broker(http://alphaworks.ibm.com/tech/rsmb) which is freely available for evaluation purposes on IBM Alphaworks. 

The Documentation of the protocol can be found here:
http://publib.boulder.ibm.com/infocenter/wmbhelp/v6r0m0/index.jsp?topic=/com.ibm.etools.mft.doc/ac10840_.htm
 

## LIMITATIONS:
This is not a reference implementation of the MQTT Protocol but does support both Publishing Messages and Subscribing to Topics with the following limitations: 
	- It only allows and supports QoS 0 Messages. I haven’t built QoS levels 1 or 2 in yet as I 	personally have no need for them but this is planned for future versions.
	- You are required to schedule pinging the server yourself (using a TTimer for examples). 	The client library implements a ping command but doesn’t automatically ping the server 	itself at regular intervals.

Note: You should also be aware that it uses part of the Synapse Internet Communications Library for its Socket support so you’ll need to ensure that this is available on your search path.


## USAGE:
There is a sample project included in the download but usage is relatively simple. This is a non-visual component so all you need to do is to put MQTT.pas and MQTTReadThread.pas  into a directory that is in your compiler paths and then put MQTT in your uses.

```delphi
uses MQTT;
var
	MQTTClient: TMQTTClient;
begin
	MQTTClient := TMQTTClient.Create('127.0.0.1', 1883);
	MQTTClient.Connect;
	MQTTClient.Publish('/dev/test', 'This is a test message.');
	MQTTClient.Disconnect;
	MQTTClient.Free;
end;
```


Special Thanks go to Andy Stanford-Clark and Nick O’Leary for their help on various “hiccups” that I encountered while developing and testing TMQTTClient.

If you are using my TMQTTClient in anything then I’d love to hear about how you’re using it, please contact me and let me know what you’re using it for.