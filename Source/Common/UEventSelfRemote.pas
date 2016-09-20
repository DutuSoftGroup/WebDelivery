{*******************************************************************************
  ����: fendou116688@163.com 2016-8-22
  ����: ģ�鹤������,������Ӧ����¼�
*******************************************************************************}
unit UEventSelfRemote;

{$I Link.Inc}
interface

uses
  Windows, Classes, UMgrPlug, UBusinessConst, ULibFun, UMITConst, UPlugConst;

type
  TEventRemoteWorker = class(TPlugEventWorker)
  public
    class function ModuleInfo: TPlugModuleInfo; override;
    procedure RunSystemObject(const nParam: PPlugRunParameter); override;
    procedure InitSystemObject; override;
    //����������ʱ��ʼ��
    procedure BeforeStartServer; override;
    //��������֮ǰ����
    procedure AfterStopServer; override;
    //����ر�֮�����
    {$IFDEF DEBUG}
    procedure GetExtendMenu(const nList: TList); override;
    {$ENDIF}
  end;

var
  gPlugRunParam: TPlugRunParameter;
  //���в���

implementation

uses
  SysUtils, USysLoger, UMgrParam;

class function TEventRemoteWorker.ModuleInfo: TPlugModuleInfo;
begin
  Result := inherited ModuleInfo;
  with Result do
  begin
    FModuleID := sPlug_ModuleRemote;
    FModuleName := '����������';
    FModuleVersion := '2016-08-22';
    FModuleDesc := '�ṩˮ��һ��ͨ�������м�����ô������';
    FModuleBuildTime:= Str2DateTime('2016-08-22 15:01:01');
  end;
end;

procedure TEventRemoteWorker.RunSystemObject(const nParam: PPlugRunParameter);
begin
end;

{$IFDEF DEBUG}
procedure TEventRemoteWorker.GetExtendMenu(const nList: TList);
var nItem: PPlugMenuItem;
begin
  New(nItem);
  nList.Add(nItem);
  nItem.FName := 'Menu_Param_3';

  nItem.FModule := ModuleInfo.FModuleID;
  nItem.FCaption := 'MIT���ò���';
  nItem.FFormID := 11;
  nItem.FDefault := False;
end;
{$ENDIF}

procedure TEventRemoteWorker.InitSystemObject;
begin
end;

procedure TEventRemoteWorker.BeforeStartServer;
begin
end;

procedure TEventRemoteWorker.AfterStopServer;
begin
end;

end.
