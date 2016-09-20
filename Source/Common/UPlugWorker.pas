{*******************************************************************************
  ����: dmzn@163.com 2013-12-07
  ����: ����ҵ����������
*******************************************************************************}
unit UPlugWorker;

{$I Link.Inc}
interface

uses
  Windows, Classes, SysUtils, ULibFun, UMgrDBConn, UBusinessWorker,
  UBusinessPacker, UBusinessConst;

type
  TPlugWorkerBase = class(TBusinessWorkerBase)
  protected
    FInBase: PBWDataBase;
    FOutBase: PBWDataBase;
    //��γ���
    FInInfo: TBWWorkerInfoType;
    FOutInfo: TBWWorkerInfoType;
    //������Ϣ
    FDataResult: string;
    //�������
    procedure SetIOData(const nIn,nOut: Pointer); virtual;
    procedure GetIOData(var nIn,nOut: Pointer); virtual;
    function DoPlugWork: Boolean; virtual; abstract;
    //����ҵ��
    procedure SetOutBaseInfo;
    //�����Ϣ
  public
    class procedure SetResult(const nData: PBWDataBase; 
      const nResult: Boolean; const nCode,nDesc: string);
    //�����ֵ
    function DoWork(var nData: string): Boolean; overload; override;
    function DoWork(const nIn,nOut: Pointer): Boolean; overload; override;
    //ִ��ҵ��
  end;

  TPlugDBWorker = class(TPlugWorkerBase)
  protected
    FErrNum: Integer;
    //������
    FDBConn: PDBWorker;
    //����ͨ��
    FDataOutNeedUnPack: Boolean;
    //�������
    function VerifyParamIn: Boolean; virtual;
    //��֤���
    function DoAfterDBWork(const nResult: Boolean): Boolean; virtual;
    function DoDBWork: Boolean; virtual; abstract;
    //����ҵ��
  public
    function DoPlugWork: Boolean; override;
    //ִ��ҵ��
  end;

implementation

uses
  UMgrParam, UEventWorker, USysLoger;

//Date: 2013-12-07
//Parm: ���;����
//Desc: ִ����nInΪ��ε�ҵ��,���nOut���
function TPlugWorkerBase.DoWork(const nIn, nOut: Pointer): Boolean;
begin
  FInBase := nIn;
  FOutBase := nOut;

  FOutInfo := itFinal;
  SetIOData(FInBase, FOutBase);
  //delivery param

  FPacker.InitData(FOutBase, False, True, False);
  //init exclude base
  
  FOutBase^ := FInBase^;
  SetResult(FOutBase, True, 'S.00', 'ҵ�����');

  Result := DoPlugWork;
  //do business

  SetOutBaseInfo;
  //fill woker info
end;

//Date: 2013-12-07
//Parm: ���������
//Desc: ��ȡ�������ݿ��������Դ
function TPlugWorkerBase.DoWork(var nData: string): Boolean;
begin
  FOutInfo := itFinal;   
  GetIOData(Pointer(FInBase), Pointer(FOutBase));
  FPacker.UnPackIn(nData, FInBase);

  FPacker.InitData(FOutBase, False, True, False);
  //init exclude base
  
  FOutBase^ := FInBase^;
  SetResult(FOutBase, True, 'S.00', 'ҵ�����');
  //default result
  
  Result := DoPlugWork;
  //do business

  if Result then
  begin
    SetOutBaseInfo;
    //fill woker info
    nData := FPacker.PackOut(FOutBase);
    //pack data
  end else
  begin
    nData := FDataResult;
    //return error message
  end;
end;

//Date: 2013-12-07
//Parm: ����;���;������;��������
//Desc: ����nData���������
class procedure TPlugWorkerBase.SetResult(const nData: PBWDataBase;
  const nResult: Boolean; const nCode,nDesc: string);
begin
  with nData^ do
  begin
    FResult := nResult;
    FErrCode := nCode;
    FErrDesc := nDesc;
  end;
end;

//Desc: �������ȡ��γ���
procedure TPlugWorkerBase.GetIOData(var nIn,nOut: Pointer);
var nStr: string;
begin
  nStr := '��������[ %s ]��֧��Զ�̵���.';
  nStr := Format(nStr, [FunctionName]);
  raise Exception.Create(nStr);
end;

//Desc: ����������γ���
procedure TPlugWorkerBase.SetIOData(const nIn,nOut: Pointer);
var nStr: string;
begin
  nStr := '��������[ %s ]��֧�ֱ��ص���.';
  nStr := Format(nStr, [FunctionName]);
  raise Exception.Create(nStr);
end;

//Desc: ��д�����Ϣ
procedure TPlugWorkerBase.SetOutBaseInfo;
  procedure SetWorkerInfo(var nInfo: TBWWorkerInfo);
  begin
    with nInfo do
    begin
      FUser   := gPlugRunParam.FLocalName;
      FIP     := gPlugRunParam.FLocalIP;
      FMAC    := gPlugRunParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := GetTickCount - FWorkTimeInit;
    end;
  end;
begin
  case FOutInfo of
   itFrom  : SetWorkerInfo(FOutBase.FFrom);
   itVia   : SetWorkerInfo(FOutBase.FVia);
   itFinal : SetWorkerInfo(FOutBase.FFinal);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2013-12-07
//Desc: ��ȡ�������ݿ��������Դ
function TPlugDBWorker.DoPlugWork: Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      FDataResult := '����[ %s ]���ݿ�ʧ��(ErrCode: %d).';
      FDataResult := Format(FDataResult, [FDB.FID, FErrNum]);
      
      SetResult(FOutBase, False, 'E.00', FDataResult);
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := False;
    //
    if not VerifyParamIn then Exit;
    //invalid input parameter

    Result := DoDBWork;
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(FDataResult, FOutBase);
      Result := DoAfterDBWork(True);
    end else DoAfterDBWork(False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Desc: ���ݿ������Ϻ���βҵ��
function TPlugDBWorker.DoAfterDBWork( const nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Desc: ��֤����Ƿ���Ч
function TPlugDBWorker.VerifyParamIn: Boolean;
begin
  Result := True;
end;

end.
