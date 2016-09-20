{*******************************************************************************
作者: fendou116688@163.com 2016/9/19
描述: Web平台服务查询
*******************************************************************************}
unit UWorkerBussinessWebchat;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, ADODB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerSelfRemote, NativeXml;

type
  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //错误码
    FDBConn: PDBWorker;
    //数据通道
    FDataIn,FDataOut: PBWDataBase;
    //入参出参
    FDataOutNeedUnPack: Boolean;
    //需要解包
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //出入参数
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //验证入参
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //数据业务
  public
    function DoWork(var nData: string): Boolean; override;
    //执行业务
    procedure WriteLog(const nEvent: string);
    //记录日志
  end;

  TBusWorkerBusinessWebchat = class(TBusinessWorkerBase)
  private
    FIn: TWorkerWebChatData;
    FOut: TWorkerWebChatData;

    procedure BuildDefaultXMLPack;
    //创建返回默认报文
    function UnPackIn(var nData: string): Boolean;
    //传入报文解包
    function VerifyPrintCode(var nData: string): Boolean;
    //验证喷码信息

    function GetWaitingForloading(var nData:string):Boolean;
    //工厂待装查询
  public
    class function FunctionName: string; override;
    function GetFlagStr(const nFlag: Integer): string; override;
    function DoWork(var nData: string): Boolean; override;
    //执行业务
    procedure WriteLog(const nEvent: string);
    //记录日志
  end;

implementation

class function TBusWorkerBusinessWebchat.FunctionName: string;
begin
  Result := sBus_BusinessWebchat;
end;

function TBusWorkerBusinessWebchat.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessWebchat;
  end;
end;

//Desc: 记录nEvent日志
procedure TBusWorkerBusinessWebchat.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TBusWorkerBusinessWebchat, 'Web平台业务' , nEvent);
end;

{
//传入参数
<?xml version="1.0" encoding="utf-8"?>
<Head>
  <Command>1</Command>
  <Data>参数</Data>
  <ExtParam>附加参数</ExtParam>
  <RemoteUL>工厂服务UL</RemoteUL>
</Head>

//传出参数
<?xml version="1.0" encoding="utf-8"?>
<DATA>
  <Items>
    <Item>
      .....
    </Item>
  </Items>
  <EXMG> ---错误描述，可多条
     < Item>
         < MsgResult> Y</ MsgResult > ---消息类型，Y成功，N失败等
         < MsgCommand> 1</ MsgCommand >----消息代码
		     < MsgTxt>减配失败，指定订单已无效</ MsgTxt > ---错误描述
     < / Item >
  </EXMG>
</DATA>
}

function TBusWorkerBusinessWebchat.UnPackIn(var nData: string): Boolean;
var nNode, nTmp: TXmlNode;
begin
  Result := False;
  FPacker.XMLBuilder.Clear;
  FPacker.XMLBuilder.ReadFromString(nData);

  //nNode := FPacker.XMLBuilder.Root.FindNode('Head');
  nNode := FPacker.XMLBuilder.Root;
  if not (Assigned(nNode) and Assigned(nNode.FindNode('Command'))) then
  begin
    nData := '无效参数节点(Head.Command Null).';
    Exit;
  end;

  if not Assigned(nNode.FindNode('RemoteUL')) then
  begin
    nData := '无效参数节点(Head.RemoteUL Null).';
    Exit;
  end;

  nTmp := nNode.FindNode('Command');
  FIn.FCommand := StrToIntDef(nTmp.ValueAsString, 0);

  nTmp := nNode.FindNode('RemoteUL');
  FIn.FRemoteUL:= nTmp.ValueAsString;

  nTmp := nNode.FindNode('Data');
  if Assigned(nTmp) then FIn.FData := nTmp.ValueAsString;

  nTmp := nNode.FindNode('ExtParam');
  if Assigned(nTmp) then FIn.FExtParam := nTmp.ValueAsString;
end;

procedure TBusWorkerBusinessWebchat.BuildDefaultXMLPack;
begin
  with FPacker.XMLBuilder do
  begin
    Clear;
    VersionString := '1.0';
    EncodingString := 'utf-8';

    XmlFormat := xfCompact;
    Root.Name := 'DATA';
    //first node
  end;
end;

function TBusWorkerBusinessWebchat.DoWork(var nData: string): Boolean;
begin
  UnPackIn(nData);

  case FIn.FCommand of
   cBC_VerifPrintCode         : Result := VerifyPrintCode(nData);
   cBC_WaitingForloading      : Result := GetWaitingForloading(nData);
   else
    begin
      Result := False;
      nData := '无效的指令代码(Invalid Command).';
    end;
  end;

  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;
end;

//------------------------------------------------------------------------------
//Date: 2016-9-20
//Parm: 防伪码
//Desc: 防伪码查询
function TBusWorkerBusinessWebchat.VerifyPrintCode(var nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
    nItems: TLadingBillItems;
    nIdx: Integer;
begin
  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
            @nOut, cBC_VerifPrintCode, FIn.FRemoteUL);
  //xxxxxx

  BuildDefaultXMLPack;
  if Result then
  begin
    with FPacker.XMLBuilder do
    begin
      with Root.NodeNew('Items') do
      begin
        AnalyseBillItems(nOut.FData, nItems);

        for nIdx := Low(nItems) to High(nItems) do
        with NodeNew('Item'), nItems[nIdx] do
        begin
          NodeNew('ID').ValueAsString := FID;

          NodeNew('CusID').ValueAsString := FCusID;
          NodeNew('CusName').ValueAsString := FCusName;

          NodeNew('Truck').ValueAsString := FTruck;
          NodeNew('StockNo').ValueAsString := FStockNo;
          NodeNew('StockName').ValueAsString := FStockName;
        end;  
      end;

      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := '业务执行成功';
        NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  end  else

  begin
    with FPacker.XMLBuilder do
    begin
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nOut.FData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  end;  

  nData := FPacker.XMLBuilder.WriteToString;
end;  

//------------------------------------------------------------------------------
//Date: 2016-9-20
//Parm: 无用
//Desc: 工厂待装查询
function TBusWorkerBusinessWebchat.GetWaitingForloading(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
    nItems: TQueueListItems;
    nIdx: Integer;
begin
  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
            @nOut, cBC_WaitingForloading, FIn.FRemoteUL);
  //xxxxxx

  BuildDefaultXMLPack;
  if Result then
  begin
    with FPacker.XMLBuilder do
    begin
      with Root.NodeNew('Items') do
      begin
        AnalyseQueueListItems(nOut.FData, nItems);

        for nIdx := Low(nItems) to High(nItems) do
        with NodeNew('Item'), nItems[nIdx] do
        begin
          NodeNew('StockName').ValueAsString := FStockName;
          NodeNew('LineCount').ValueAsString := IntToStr(FLineCount);
          NodeNew('TruckCount').ValueAsString := IntToStr(FTruckCount);
        end;  
      end;

      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := '业务执行成功';
        NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  end
  else begin
    with FPacker.XMLBuilder do
    begin
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nOut.FData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  end;  
  nData := FPacker.XMLBuilder.WriteToString;
end;


//------------------------------------------------------------------------------
//Date: 2012-3-13
//Parm: 如参数护具
//Desc: 获取连接数据库所需的资源
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '连接数据库失败(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      nData := FPacker.PackOut(FDataOut);

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Date: 2012-3-22
//Parm: 输出数据;结果
//Desc: 数据业务执行完毕后的收尾操作
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: 入参数据
//Desc: 验证入参数据是否有效
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: 记录nEvent日志
procedure TMITDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMITDBWorker, FunctionName, nEvent);
end;


initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerBusinessWebchat, sPlug_ModuleBus);
end.
