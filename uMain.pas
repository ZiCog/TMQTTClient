unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MQTT, MQTTReadThread, ExtCtrls, ShellAPI;

type
  TfMain = class(TForm)
    btnConnect: TButton;
    btnDisconnect: TButton;
    btnPublish: TButton;
    eTopic: TEdit;
    eMessage: TEdit;
    eIP: TEdit;
    ePort: TEdit;
    btnPing: TButton;
    btnSubscribe: TButton;
    eSubTopic: TEdit;
    mStatus: TMemo;
    lblHeader: TLabel;
    lnlMQTTInfo: TLabel;
    lblMQTTUrl: TLabel;
    lblPrimarilyTested: TLabel;
    lblRSMBUrl: TLabel;
    lblLimits: TLabel;
    lblLimits2: TLabel;
    lblSynapse: TLabel;
    procedure btnConnectClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure btnPublishClick(Sender: TObject);
    procedure btnPingClick(Sender: TObject);
    procedure OnConnAck(Sender: TObject; ReturnCode: integer);
    procedure OnPingResp(Sender: TObject);
    procedure OnSubAck(Sender: TObject; MessageID: integer; GrantedQoS: integer);
    procedure OnUnSubAck(Sender: TObject);
    procedure OnPublish(Sender: TObject; topic, payload: string);
    procedure btnSubscribeClick(Sender: TObject);
    procedure lblUrlClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fMain: TfMain;
  MQTTClient: TMQTTClient;
  fRL: TBytes;

implementation

{$R *.dfm}

procedure TfMain.OnPublish(Sender: TObject; topic, payload: string);
begin
  mStatus.Lines.Add('Publish Received. Topic: '+ topic + ' Payload: ' + payload);
end;

procedure TfMain.OnSubAck(Sender: TObject; MessageID: integer; GrantedQoS: integer);
begin
  mStatus.Lines.Add('Sub Ack Received');
end;

procedure TfMain.OnUnSubAck(Sender: TObject);
begin
  mStatus.Lines.Add('Unsubscribe Ack Received');
end;

procedure TfMain.OnConnAck(Sender: TObject; ReturnCode: integer);
begin
  mStatus.Lines.Add('Connection Acknowledged, Return Code: ' + IntToStr(Ord(ReturnCode)));
end;

procedure TfMain.OnPingResp(Sender: TObject);
begin
  mStatus.Lines.Add('PING! PONG!');
end;

procedure TfMain.btnConnectClick(Sender: TObject);
begin
  MQTTClient := TMQTTClient.Create(eIP.Text, StrToInt(ePort.Text));
  MQTTClient.OnConnAck := OnConnAck;
  MQTTClient.OnPingResp := OnPingResp;
  MQTTClient.OnPublish := OnPublish;
  MQTTClient.OnSubAck := OnSubAck;
  MQTTClient.Connect;
end;

procedure TfMain.btnDisconnectClick(Sender: TObject);
begin
  MQTTClient.Disconnect;
end;

procedure TfMain.btnPingClick(Sender: TObject);
begin
  MQTTClient.PingReq;
end;

procedure TfMain.btnPublishClick(Sender: TObject);
begin
  MQTTClient.Publish(eTopic.Text, eMessage.Text);
end;

procedure TfMain.btnSubscribeClick(Sender: TObject);
begin
  MQTTClient.Subscribe(eSubTopic.Text);
end;

procedure TfMain.lblUrlClick(Sender: TObject);
begin
  ShellExecute(self.WindowHandle,'open',PChar((Sender as TLabel).Caption),nil,nil, SW_SHOWNORMAL);
end;

end.
