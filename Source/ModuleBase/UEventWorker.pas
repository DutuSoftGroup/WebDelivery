{*******************************************************************************
  ����: dmzn@163.com 2013-11-23
  ����: ģ�鹤������,������Ӧ����¼�
*******************************************************************************}
unit UEventWorker;

interface

uses
  Windows, Classes, UMgrPlug, UBusinessConst, ULibFun, UPlugConst;

type
  TPlugWorker = class(TPlugEventWorker)
  public
    class function ModuleInfo: TPlugModuleInfo; override;
    procedure RunSystemObject(const nParam: PPlugRunParameter); override;
  end;

var
  gPlugRunParam: TPlugRunParameter;
  //���в���

implementation

class function TPlugWorker.ModuleInfo: TPlugModuleInfo;
begin
  Result := inherited ModuleInfo;
  with Result do
  begin
    FModuleID := '';
    FModuleName := '����ģ��';
  end;
end;

procedure TPlugWorker.RunSystemObject(const nParam: PPlugRunParameter);
begin
  gPlugRunParam := nParam^;
end;

end.
