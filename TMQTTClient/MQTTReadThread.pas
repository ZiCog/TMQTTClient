{
 -------------------------------------------------
  MQTTReadThread.pas -  Contains the socket receiving thread that is part of the
  TMQTTClient library (MQTT.pas).

  MIT License -  http://www.opensource.org/licenses/mit-license.php
  Copyright (c) 2009 Jamie Ingilby

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  -------------------------------------------------
}
unit MQTTReadThread;

interface

uses
  SysUtils, Classes, blcksock;

type
  TMQTTMessage = Record
    FixedHeader: Byte;
    RL: TBytes;
    Data: TBytes;
  End;

  PTCPBlockSocket = ^TTCPBlockSocket;

  TConnAckEvent = procedure (Sender: TObject; ReturnCode: integer) of object;
  TPublishEvent = procedure (Sender: TObject; topic, payload: string) of object;
  TPingRespEvent = procedure (Sender: TObject) of object;
  TSubAckEvent = procedure (Sender: TObject; MessageID: integer; GrantedQoS: integer) of object;
  TUnSubAckEvent = procedure (Sender: TObject; MessageID: integer) of object;

  TMQTTReadThread = class(TThread)
  private
    FPSocket: PTCPBlockSocket;
    FCurrentData: TMQTTMessage;
    // Events
    FConnAckEvent: TConnAckEvent;
    FPublishEvent: TPublishEvent;
    FPingRespEvent: TPingRespEvent;
    FSubAckEvent: TSubAckEvent;
    FUnSubAckEvent: TUnSubAckEvent;
    // This takes a 1-4 Byte Remaining Length bytes as per the spec and returns the Length value it represents
    function RemainingLengthToInt(RLBytes: TBytes): Integer;
    // Increases the size of the Dest array and Appends NewBytes to the end of DestArray 
    procedure AppendBytes(var DestArray: TBytes; const NewBytes: TBytes);
    // Takes a 2 Byte Length array and returns the length of the string it preceeds as per the spec.
    function BytesToStrLength(LengthBytes: TBytes): integer;
    // This is our data processing and event firing command. To be called via Synchronize.
    procedure HandleData;
  protected
    procedure Execute; override;
  public
    constructor Create(Socket: PTCPBlockSocket);
    property OnConnAck : TConnAckEvent read FConnAckEvent write FConnAckEvent;
    property OnPublish : TPublishEvent read FPublishEvent write FPublishEvent;
    property OnPingResp : TPingRespEvent read FPingRespEvent write FPingRespEvent;
    property OnSubAck : TSubAckEvent read FSubAckEvent write FSubAckEvent;
    property OnUnSubAck : TUnSubAckEvent read FUnSubAckEvent write FUnSubAckEvent;
  end;

implementation

uses
  MQTT;

{ TMQTTReadThread }

constructor TMQTTReadThread.Create(Socket: PTCPBlockSocket);
begin
  inherited Create(true);
  FPSocket := Socket;
  FreeOnTerminate := true;
end;

procedure TMQTTReadThread.Execute;
var
  CurrentMessage: TMQTTMessage;
  RLInt: Integer;
  Buffer: TBytes;
  i: integer;
begin
  while not Terminated do
    begin
      CurrentMessage.FixedHeader := 0;
      CurrentMessage.RL := nil;
      CurrentMessage.Data := nil;
      CurrentMessage.FixedHeader := FPSocket^.RecvByte(1000);
      // If we couldn't read from the socket try to read the rest of the message.
      if not ((FPSocket^.LastError <> 0) and (CurrentMessage.FixedHeader = 0)) then
        begin
          SetLength(CurrentMessage.RL, 1);
          SetLength(Buffer, 1);
          CurrentMessage.RL[0] := FPSocket^.RecvByte(1000);
          for i := 1 to 3 do
            begin
              if (( CurrentMessage.RL[i - 1] and 128) <> 0) then
              begin
                Buffer[0] := FPSocket^.RecvByte(1000);
                AppendBytes(CurrentMessage.RL, Buffer);
              end else Break;
            end;

          RLInt := RemainingLengthToInt(CurrentMessage.RL);
          if (RLInt > 0)  then
            begin
              SetLength(CurrentMessage.Data, RLInt);
              FPSocket^.RecvBufferEx(Pointer(CurrentMessage.Data), RLInt, 1000);
            end;

          if not (FPSocket^.LastError <> 0) then
            begin
              //ProcessCommand.
              FCurrentData := CurrentMessage;
              Synchronize(HandleData);
            end;
        end;
    end;
end;

procedure TMQTTReadThread.HandleData;
var
  MessageType: Byte;
  DataLen: integer;
  QoS: integer;
  Topic: string;
  Payload: string;
  ResponseVH: TBytes;
  ConnectReturn: Integer;
begin
  if (FCurrentData.FixedHeader <> 0) then
    begin
      MessageType := FCurrentData.FixedHeader shr 4;

      if (MessageType = Ord(MQTT.CONNACK)) then
        begin
          // Check if we were given a Connect Return Code.
          ConnectReturn := 0;
          // Any return code except 0 is an Error
          if ((Length(FCurrentData.Data) > 0) and (Length(FCurrentData.Data) < 4)) then
            begin
              ConnectReturn := FCurrentData.Data[1];
              Exception.Create('Connect Error Returned by the Broker. Error Code: ' + IntToStr(FCurrentData.Data[1]));
            end;
          if Assigned(OnConnAck) then OnConnAck(Self, ConnectReturn);
        end
      else
      if (MessageType = Ord(MQTT.PUBLISH)) then
        begin
          // Read the Length Bytes
          DataLen := BytesToStrLength(Copy(FCurrentData.Data, 0, 2));
          // Get the Topic
          SetString(Topic, PChar(@FCurrentData.Data[2]), DataLen);
          // Get the Payload
          SetString(Payload, PChar(@FCurrentData.Data[2 + DataLen]), (Length(FCurrentData.Data) - 2 - DataLen));
          if Assigned(OnPublish) then OnPublish(Self, Topic, Payload);
        end
      else
      if (MessageType = Ord(MQTT.SUBACK)) then
        begin
          // Reading the Message ID
          ResponseVH := Copy(FCurrentData.Data, 0, 2);
          DataLen := BytesToStrLength(ResponseVH);
          // Next Read the Granted QoS
          QoS := 0;
          if (Length(FCurrentData.Data) - 2) > 0 then
            begin
              ResponseVH := Copy(FCurrentData.Data, 2, 1);
              QoS := ResponseVH[0];
            end;
          if Assigned(OnSubAck) then OnSubAck(Self, DataLen, QoS);
        end
      else
      if (MessageType = Ord(MQTT.UNSUBACK)) then
        begin
          // Read the Message ID for the event handler
          ResponseVH := Copy(FCurrentData.Data, 0, 2);
          DataLen := BytesToStrLength(ResponseVH);
          if Assigned(OnUnSubAck) then OnUnSubAck(Self, DataLen);
        end
      else
      if (MessageType = Ord(MQTT.PINGRESP)) then
        begin
          if Assigned(OnPingResp) then OnPingResp(Self);
        end;
    end;
end;

function TMQTTReadThread.BytesToStrLength(LengthBytes: TBytes): integer;
begin
  Assert(Length(LengthBytes) = 2, 'UTF-8 Length Bytes preceeding the text must be 2 Bytes in Legnth');

  Result := 0;
  Result := LengthBytes[0] shl 8;
  Result := Result + LengthBytes[1];
end;

function TMQTTReadThread.RemainingLengthToInt(RLBytes: TBytes): Integer;
var
  multi: integer;
  i: integer;
  digit: Byte;
begin
  multi := 1;
  i := 0;
  Result := 0;

  digit := RLBytes[i];
  repeat
    digit := RLBytes[i];
    Result := Result + (digit and 127) * multi;
    multi := multi * 128;
    Inc(i);
  until ((digit and 128) = 0);
end;

procedure TMQTTReadThread.AppendBytes(var DestArray: TBytes;
  const NewBytes: TBytes);
var
  DestLen: Integer;
begin
  DestLen := Length(DestArray);
  SetLength(DestArray, DestLen + Length(NewBytes));
  Move(NewBytes, DestArray[DestLen], Length(NewBytes));
end;

end.
