program MQTT_Test;

uses
  Forms,
  uMain in 'uMain.pas' {fMain},
  SiAuto,
  MQTTReadThread in 'TMQTTClient\MQTTReadThread.pas',
  MQTT in 'TMQTTClient\MQTT.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Si.Enabled := True;
  Application.Run;
end.
