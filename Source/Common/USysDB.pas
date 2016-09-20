{*******************************************************************************
  ����: dmzn@163.com 2008-08-07
  ����: ϵͳ���ݿⳣ������

  ��ע:
  *.�Զ�����SQL���,֧�ֱ���:$Inc,����;$Float,����;$Integer=sFlag_Integer;
    $Decimal=sFlag_Decimal;$Image,��������
*******************************************************************************}
unit USysDB;

{$I Link.inc}
interface

uses
  SysUtils, Classes;

const
  cSysDatabaseName: array[0..4] of String = (
     'Access', 'SQL', 'MySQL', 'Oracle', 'DB2');
  //db names

type
  TSysDatabaseType = (dtAccess, dtSQLServer, dtMySQL, dtOracle, dtDB2);
  //db types

  PSysTableItem = ^TSysTableItem;
  TSysTableItem = record
    FTable: string;
    FNewSQL: string;
  end;
  //ϵͳ����

var
  gSysTableList: TList = nil;                        //ϵͳ������
  gSysDBType: TSysDatabaseType = dtSQLServer;        //ϵͳ��������

//------------------------------------------------------------------------------
const
  //�����ֶ�
  sField_Access_AutoInc          = 'Counter';
  sField_SQLServer_AutoInc       = 'Integer IDENTITY (1,1) PRIMARY KEY';

  //С���ֶ�
  sField_Access_Decimal          = 'Float';
  sField_SQLServer_Decimal       = 'Decimal(15, 5)';

  //ͼƬ�ֶ�
  sField_Access_Image            = 'OLEObject';
  sField_SQLServer_Image         = 'Image';

  //�������
  sField_SQLServer_Now           = 'getDate()';

ResourceString     
  {*Ȩ����*}
  sPopedom_Read       = 'A';                         //���
  sPopedom_Add        = 'B';                         //���
  sPopedom_Edit       = 'C';                         //�޸�
  sPopedom_Delete     = 'D';                         //ɾ��
  sPopedom_Preview    = 'E';                         //Ԥ��
  sPopedom_Print      = 'F';                         //��ӡ
  sPopedom_Export     = 'G';                         //����

  {*��ر��*}
  sFlag_Yes           = 'Y';                         //��
  sFlag_No            = 'N';                         //��
  sFlag_Unknow        = 'U';                         //δ֪        
  sFlag_Enabled       = 'Y';                         //����
  sFlag_Disabled      = 'N';                         //����

  sFlag_Integer       = 'I';                         //����
  sFlag_Decimal       = 'D';                         //С��

  sFlag_NotMatter     = '@';                         //�޹ر��(�����Ŷ���)
  sFlag_ForceDone     = '#';                         //ǿ�����(δ���ǰ����)
  sFlag_FixedNo       = '$';                         //ָ�����(ʹ����ͬ���)

  sFlag_Provide       = 'P';                         //��Ӧ
  sFlag_Sale          = 'S';                         //����
  sFlag_Other         = 'O';                         //����

  sFlag_Dai           = 'D';                         //��װ
  sFlag_PoundDai      = 'P';                         //��װ(�������)
  sFlag_San           = 'S';                         //ɢװ
  sFlag_PoundSan      = 'B';                         //ɢװ(�������)

  sFlag_PoundBZ       = 'B';                         //��׼
  sFlag_PoundPZ       = 'Z';                         //Ƥ��
  sFlag_PoundPD       = 'P';                         //���
  sFlag_PoundCC       = 'C';                         //����(����ģʽ)

  sFlag_XS            = 'X';                         //����
  sFlag_ZC            = 'Z';                         //ת��

  sFlag_TiHuo         = 'T';                         //����
  sFlag_SongH         = 'S';                         //�ͻ�
  sFlag_XieH          = 'X';                         //��ж

  sFlag_BillNew       = 'N';                         //�µ�
  sFlag_BillEdit      = 'E';                         //�޸�
  sFlag_BillDel       = 'D';                         //ɾ��
  sFlag_BillLading    = 'L';                         //�����
  sFlag_BillPick      = 'P';                         //����
  sFlag_BillPost      = 'G';                         //����
  sFlag_BillDone      = 'O';                         //���
  sFlag_BillZRE       = 'ZRE';                       //�˻�����
  sFlag_BillZLR       = 'ZLR';                       //�˻������� ZLR       //TANXIN 2013-03-21
  sFlag_BillZNR1       = 'ZNR1';                     //�˻������� ZNR1
  sFlag_BillZNR2       = 'ZNR2';                     //�˻������� ZNR2
  sFlag_BillZNR3       = 'ZNR3';                     //�˻������� ZNR3
  sFlag_BillZRL1       = 'ZRL1';                     //�˻������� ZRL1
  sFlag_BillZRL2       = 'ZRL2';                     //�˻������� ZRL2
  sFlag_BillZRL3       = 'ZRL3';                     //�˻������� ZRL3

  sFlag_TypeShip      = 'S';                         //����
  sFlag_TypeZT        = 'Z';                         //ջ̨
  sFlag_TypeVIP       = 'V';                         //VIP
  sFlag_TypeCommon    = 'C';                         //��ͨ,��������

  sFlag_TruckNone     = 'N';                         //��״̬����
  sFlag_TruckIn       = 'I';                         //��������
  sFlag_TruckOut      = 'O';                         //��������
  sFlag_TruckBFP      = 'P';                         //����Ƥ�س���
  sFlag_TruckBFM      = 'M';                         //����ë�س���
  sFlag_TruckSH       = 'S';                         //�ͻ�����
  sFlag_TruckFH       = 'F';                         //�Żҳ���
  sFlag_TruckZT       = 'Z';                         //ջ̨����
  sFlag_TruckMIT      = 'T';                         //������MIT
  sFlag_TruckSAP      = 'A';                         //������SAP

  sFlag_CardIdle      = 'I';                         //���п�
  sFlag_CardUsed      = 'U';                         //ʹ����
  sFlag_CardLoss      = 'L';                         //��ʧ��
  sFlag_CardInvalid   = 'N';                         //ע����

  sFlag_SerialSAP     = 'SAPFunction';               //SAP������
  sFlag_SAPMsgNo      = 'SAP_MsgNo';                 //SAP��Ϣ��
  sFlag_ForceHint     = 'Bus_HintMsg';               //ǿ����ʾ

  sFlag_SerailSYS     = 'SYSTableID';                //SYS������
  sFlag_TruckLog      = 'SYS_TruckLog';              //������¼
  sFlag_PoundLog      = 'SYS_PoundLog';              //������¼

  sFlag_SysParam      = 'SysParam';                  //ϵͳ����
  sFlag_Company       = 'Company';                   //��˾��
  sFlag_JBTime        = 'JiaoBanTime';               //����ʱ��
  sFlag_JBParam       = 'JiaoBanParam';              //�������
  sFlag_AutoIn        = 'Truck_AutoIn';              //�Զ�����
  sFlag_AutoOut       = 'Truck_AutoOut';             //�Զ�����
  sFlag_InTimeout     = 'InFactTimeOut';             //������ʱ(����)
  sFlag_NoDaiQueue    = 'NoDaiQueue';                //��װ���ö���
  sFlag_NoSanQueue    = 'NoSanQueue';                //ɢװ���ö���
  sFlag_DelayQueue    = 'DelayQueue';                //�ӳ��Ŷ�(����)
  sFlag_EnableBakdb   = 'Uses_BackDB';               //���ÿ�
  sFlag_CusType       = 'CustomerType';              //�ͻ�����
  sFlag_SAPSrvURL     = 'SAPServiceURL';
  sFlag_MITSrvURL     = 'MITServiceURL';
  sFlag_CRMSrvURL     = 'CRMServiceURL';             //CRM����          20130524
  sFlag_CRMMessURL    = 'CRMMessURL';                //CRM����          20130603
  sFlag_HardSrvURL    = 'HardMonURL';
  sFlag_ServerIP      = 'ServerHostIP';              //�����ַ
  sFlag_UpdateServer  = 'UpdateServer';              
  sFlag_UpdateUser    = 'UpdateUser';                //��������
  sFlag_ViaBillCard   = 'ViaBillCard';               //ֱ���ƿ�
  sFlag_PrintBill     = 'PrintStockBill';            //���ӡ����
  sFlag_NFStock       = 'NoFaHuoStock';              //�޷���Ʒ��
  sFlag_LineStock     = 'LineStock';                 //ͨ��Ʒ��
  sFlag_PoundID       = 'PoundID';                   //��վ���
  sFlag_PDaiWuChaZ    = 'PoundDaiWuChaZ';            //�������         20130708
  sFlag_PDaiWuChaF    = 'PoundDaiWuChaF';            //�������         20130708
  sFlag_PoundWuCha    = 'PoundWuCha';                //�������
  sFlag_PoundWarning  = 'PoundWarning';              //Ƥ��Ԥ��         20130703
                                                                 
  sFlag_LoadMaterails = 'LoadMaterails';             //��������
  sFlag_PoundIfDai    = 'PoundIFDai';                //��װ����
  sFlag_ZYPoint       = 'OrderZYPoint';              //װ�˵�
  sFlag_TruckQueue    = 'TruckQueue';                //��������

  {*���ݱ�*}
  sTable_Group        = 'Sys_Group';                 //�û���
  sTable_User         = 'Sys_User';                  //�û���
  sTable_Menu         = 'Sys_Menu';                  //�˵���
  sTable_Popedom      = 'Sys_Popedom';               //Ȩ�ޱ�
  sTable_PopItem      = 'Sys_PopItem';               //Ȩ����
  sTable_Entity       = 'Sys_Entity';                //�ֵ�ʵ��
  sTable_DictItem     = 'Sys_DataDict';              //�ֵ���ϸ

  sTable_SysDict      = 'Sys_Dict';                  //ϵͳ�ֵ�
  sTable_ExtInfo      = 'Sys_ExtInfo';               //������Ϣ
  sTable_SysLog       = 'Sys_EventLog';              //ϵͳ��־
  sTable_BaseInfo     = 'Sys_BaseInfo';              //������Ϣ
  sTable_SerialBase   = 'Sys_SerialBase';            //��������
  sTable_SerialStatus = 'Sys_SerialStatus';          //���״̬

  sTable_StorLocation = 'S_StockLocation';           //����
  sTable_StockMatch   = 'S_StockMatch';              //Ʒ��ӳ��
  sTable_Bill         = 'S_Bill';                    //������
  sTable_BillInfo     = 'S_BillInfo';                //��չ��Ϣ
  sTable_OrderXS      = 'S_OrderXS';                 //���۶�����Ϣ
  sTable_OrderZC      = 'S_OrderZC';                 //ת��������Ϣ
  sTable_Card         = 'S_Card';                    //���۴ſ�

  sTable_Truck        = 'S_Truck';                   //������
  sTable_TruckLog     = 'S_TruckLog';                //������־

  sTable_Customer     = 'S_Customer';                //�ͻ���
  sTable_Materails    = 'S_Materails';               //���ϱ�
  sTable_PoundLog     = 'S_PoundLog';                //��������
  sTable_PoundBak     = 'S_PoundBak';                //��������

  sTable_ZTLines      = 'S_ZTLines';                 //װ����
  sTable_ZTTrucks     = 'S_ZTTrucks';                //��������
  sTable_ZTTruckLog   = 'S_ZTTruckLog';              //װ����¼

  sTable_Message      = 'M_Message';                 //���ż�¼         20130605
  sTable_MTime        = 'M_Time';                    //ʱ������
  sTable_MUser        = 'M_User';                    //��Ա����
  sTable_Template     = 'M_Template';                //����ģ��         21030725
  sTable_Definition   = 'M_Definition';              //���Ŷ���         20130725

  {*�½���*}
  sSQL_NewMessage = 'Create Table $Table(L_Note varChar(500), L_Message varChar(500),' +
       'L_Date varChar(50))';
  {-----------------------------------------------------------------------------
   ���ż�¼: M_Message
   *.L_Note: ����
   *.L_Message: ����
   *.L_Date: ʱ��
  -----------------------------------------------------------------------------}
  sSQL_NewMTime = 'Create Table $Table(T_Id $Inc, T_Time varChar(50),' +
       'T_LastTime varChar(50),D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   ʱ������: M_MTime
   *.T_Id: ���
   *.T_Time: ����ʱ��
   *.T_LastTime: ����ʱ��
  -----------------------------------------------------------------------------}
  sSQL_NewMUser = 'Create Table $Table(M_Note varChar(50), M_Name varChar(50))';
  {-----------------------------------------------------------------------------
   ��Ա����: M_MUser
   *.M_Note: ����
   *.M_Name: ����                                              //���ӱ� 20130613
   -----------------------------------------------------------------------------}
  sSQL_NewMDefinition = 'Create Table $Table(D_ID $Inc, D_Definition varChar(50),' +
         'D_SQL varChar(50),D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   �궨������: M_Definition
   *.D_ID: ���
   *.D_Definition: �궨��
   *.D_SQL: SQL                                                //���ӱ� 20130808
  -----------------------------------------------------------------------------}
  sSQL_NewMTemplate = 'Create Table $Table(T_ID $Inc, T_Template varChar(500),' +
         'D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   ģ������: M_Template
   *.T_ID: ģ����
   *.T_Template: ģ������                                      //���ӱ� 20130808
  -----------------------------------------------------------------------------}
  sSQL_NewSysDict = 'Create Table $Table(D_ID $Inc, D_Name varChar(15),' +
       'D_Desc varChar(30), D_Value varChar(50), D_Memo varChar(20),' +
       'D_ParamA $Float, D_ParamB varChar(50), D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   ϵͳ�ֵ�: SysDict
   *.D_ID: ���
   *.D_Name: ����
   *.D_Desc: ����
   *.D_Value: ȡֵ
   *.D_Memo: �����Ϣ
   *.D_ParamA: �������
   *.D_ParamB: �ַ�����
   *.D_Index: ��ʾ����
  -----------------------------------------------------------------------------}

  sSQL_NewExtInfo = 'Create Table $Table(I_ID $Inc, I_Group varChar(20),' +
       'I_ItemID varChar(20), I_Item varChar(30), I_Info varChar(500),' +
       'I_ParamA $Float, I_ParamB varChar(50), I_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   ��չ��Ϣ��: ExtInfo
   *.I_ID: ���
   *.I_Group: ��Ϣ����
   *.I_ItemID: ��Ϣ��ʶ
   *.I_Item: ��Ϣ��
   *.I_Info: ��Ϣ����
   *.I_ParamA: �������
   *.I_ParamB: �ַ�����
   *.I_Memo: ��ע��Ϣ
   *.I_Index: ��ʾ����
  -----------------------------------------------------------------------------}
  
  sSQL_NewSysLog = 'Create Table $Table(L_ID $Inc, L_Date DateTime,' +
       'L_Man varChar(32),L_Group varChar(20), L_ItemID varChar(20),' +
       'L_KeyID varChar(20), L_Event varChar(220))';
  {-----------------------------------------------------------------------------
   ϵͳ��־: SysLog
   *.L_ID: ���
   *.L_Date: ��������
   *.L_Man: ������
   *.L_Group: ��Ϣ����
   *.L_ItemID: ��Ϣ��ʶ
   *.L_KeyID: ������ʶ
   *.L_Event: �¼�
  -----------------------------------------------------------------------------}

  sSQL_NewBaseInfo = 'Create Table $Table(B_ID $Inc, B_Group varChar(15),' +
       'B_Text varChar(100), B_Py varChar(25), B_Memo varChar(50),' +
       'B_PID Integer, B_Index Float)';
  {-----------------------------------------------------------------------------
   ������Ϣ��: BaseInfo
   *.B_ID: ���
   *.B_Group: ����
   *.B_������Text: ����
   *.B_Py: ƴ����д
   *.B_Memo: ��ע��Ϣ
   *.B_PID: �ϼ��ڵ�
   *.B_Index: ����˳��
  -----------------------------------------------------------------------------}

  sSQL_NewSerialBase = 'Create Table $Table(B_ID $Inc, B_Group varChar(15),' +
       'B_Object varChar(32), B_Prefix varChar(25), B_IDLen Integer,' +
       'B_Base Integer)';
  {-----------------------------------------------------------------------------
   ���б�Ż�����: SerialBase
   *.B_ID: ���
   *.B_Group: ����
   *.B_Object: ����
   *.B_Prefix: ǰ׺
   *.B_IDLen: ��ų�
   *.B_Base: ����
  -----------------------------------------------------------------------------}

  sSQL_NewSerialStatus = 'Create Table $Table(S_ID $Inc, S_Object varChar(32),' +
       'S_SerailID varChar(32), S_PairID varChar(32), S_Status Char(1),' +
       'S_Date DateTime)';
  {-----------------------------------------------------------------------------
   ����״̬��: SerialStatus
   *.S_ID: ���
   *.S_Object: ����
   *.S_SerailID: ���б��
   *.S_PairID: ��Ա��
   *.S_Status: ״̬(Y,N)
   *.S_Date: ����ʱ��
  -----------------------------------------------------------------------------}

  sSQL_NewStorLocation = 'Create Table $Table(L_ID $Inc, L_Name varChar(52),' +
       'L_PY varChar(52), L_Factory varChar(8), L_Locate varChar(8))';
  {-----------------------------------------------------------------------------
   ����: StockLocation
   *.L_ID: ���
   *.L_Name: �ִ���
   *.L_PY: ƴ��
   *.L_Factory: �������
   *.L_Locate: ��λ
  -----------------------------------------------------------------------------}

  sSQL_NewStockMatch = 'Create Table $Table(R_ID $Inc, M_Group varChar(8),' +
       'M_ID varChar(20), M_Name varChar(80), M_Status Char(1))';
  {-----------------------------------------------------------------------------
   ����Ʒ��ӳ��: StockMatch
   *.R_ID: ��¼���
   *.M_Group: �ִ���
   *.M_ID: ���Ϻ�
   *.M_Name: ��������
   *.M_Status: ״̬
  -----------------------------------------------------------------------------}

  sSQL_NewBill = 'Create Table $Table(R_ID $Inc, L_ID varChar(20),' +
       'L_Card varChar(16), L_Type Char(1), L_Stock varChar(80),' +
       'L_StockNo varChar(20), L_Truck varChar(50), L_TruckID varChar(15),' +
       'L_Value $Float, L_CusType varChar(8), L_CusID varChar(20),' +
       'L_CusName varChar(82), L_CusPY varChar(82),' +
       'L_Order Char(1), L_OrderID varChar(20),' +
       'L_Seal varChar(100), L_IsVIP varChar(1),' +
       'L_Man varChar(32), L_Date DateTime,' +
       'L_PickDate DateTime, L_PickMan varChar(32),' +
       'L_PostDay varChar(10), L_PostDate DateTime, L_PostMan varChar(32),' +
       'L_FactNum varChar(8), L_OutNum varChar(35), L_OutFact DateTime,' +
       'L_Status Char(1), L_Action Char(1), L_Result Char(1),' +
       'L_ExtInfo Integer Default 0, L_ExtRes Integer Default 0,' +
       'L_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   ��������: Bill
   *.R_ID: ���
   *.L_ID: �ᵥ��
   *.L_Card: �ſ���
   *.L_Type: ����(��,ɢ)
   *.L_Stock: ��������
   *.L_StockNo: ���ϱ��
   *.L_Truck: ������
   *.L_TruckID: �����¼
   *.L_Value: ������
   *.L_CusType: �ͻ�����
   *.L_CusID: �ͻ����
   *.L_CusName: �ͻ�����
   *.L_CusPY: ƴ����д
   *.L_Order: ��������(����,ת��)
   *.L_OrderID: ������
   *.L_Seal: ��ǩ��
   *.L_IsVIP: VIP��
   *.L_Man:������
   *.L_Date:����ʱ��
   *.L_PickDate: ����ʱ��
   *.L_PickMan: ������Ա
   *.L_PostDay: ������(����)
   *.L_PostDate: ����ʱ��
   *.L_PostMan: ������
   *.L_FactNum: �������
   *.L_OutNum: �������
   *.L_OutFact: ��������
   *.L_Status: ��ǰ״̬
   *.L_Action: ��һ����
   *.L_Result: �������
   *.L_ExtInfo: ��չ�������
   *.L_ExtRes: ��չResponse����
   *.L_Memo: ������ע
  -----------------------------------------------------------------------------}

  sSQL_NewBillInfo = 'Create Table $Table(R_ID $Inc,VBELN varChar(20),' +
       'LFART varChar(8),VTEXT varChar(40),KUNNR_AG varChar(20),' +
       'NAME1_AG varChar(70),KUNNR_WE varChar(20),NAME1_WE varChar(70),' +
       'KUNNR_RE varChar(20),NAME1_RE varChar(70),KUNNR_RG varChar(20),' +
       'NAME1_RG varChar(70),VSTEL varChar(8),VSEXT varChar(60),' +
       'VKBUR varChar(8),BEZEI20 varChar(40),BZIRK varChar(12),' +
       'BZTXT varChar(40),ZSCDW varChar(40),KDGRP varChar(4),' +
       'KTEXT varChar(40),VSART varChar(4),VSZEI varChar(40),' +
       'ZCODE_QY varChar(10),ZDESC_QY varChar(40),ZCODE_SY varChar(20),' +
       'ZDESC_SY varChar(40),SORT1 varChar(40),SORT2 varChar(40),' +
       'VBELN_CT varChar(20),LIFNR_CT varChar(20),KOQUK varChar(2),' +
       'WBSTK varChar(2),PDSTK varChar(2),FKSTK varChar(2),FKIVK varChar(2),' +

       'POSNR $Float,VBELN_G varChar(20),POSNR_G $Float,VBELN_C varChar(20),' +
       'POSNR_C $Float,LFIMG $Float,MATNR varChar(36),ARKTX varChar(80),' +
       'WERKS varChar(8),NAME1 varChar(60),LGORT varChar(8),' +
       'LGOBE varChar(32),SPART varChar(4),SPEXT varChar(40),MVGR1 varChar(6),' +
       'BEZEI varChar(80),KDMAT varChar(70),CHARG varChar(20),' +
       'VTWEG varChar(4),VTEXT20 varChar(40),ZCCJ $Float)';

  sSQL_NewCard = 'Create Table $Table(R_ID $Inc, C_Card varChar(16),' +
       'C_Card2 varChar(32), C_Card3 varChar(32),' +
       'C_Owner varChar(15), C_TruckNo varChar(15), C_Status Char(1),' +
       'C_Freeze Char(1), C_Used Char(1), C_UseTime Integer Default 0,' +
       'C_Man varChar(32), C_Date DateTime, C_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   �ſ���:Card
   *.R_ID:��¼���
   *.C_Card:������
   *.C_Card2,C_Card3:������
   *.C_Owner:�����˱�ʶ
   *.C_TruckNo:�������
   *.C_Used:��;(��Ӧ,����)
   *.C_UseTime:ʹ�ô���
   *.C_Status:״̬(����,ʹ��,ע��,��ʧ)
   *.C_Freeze:�Ƿ񶳽�
   *.C_Man:������
   *.C_Date:����ʱ��
   *.C_Memo:��ע��Ϣ
  -----------------------------------------------------------------------------}

  sSQL_NewTruck = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15), ' +
       'T_PY varChar(15), T_Owner varChar(32), T_Phone varChar(15), ' +
       'T_Used Char(1), T_PrePValue $Float, T_PrePMan varChar(32), ' +
       'T_PrePTime DateTime, T_Man varChar(32), T_Valid Char(1))';
  {-----------------------------------------------------------------------------
   ������Ϣ:Truck
   *.R_ID: ��¼��
   *.T_Truck: ���ƺ�
   *.T_PY: ����ƴ��
   *.T_Owner: ����
   *.T_Phone: ��ϵ��ʽ
   *.T_Used: ��;(��Ӧ,����)
   *.T_PrePValue: Ԥ��Ƥ��
   *.T_PrePMan: Ԥ��˾��
   *.T_PrePTime: Ԥ��ʱ��
   *.T_Valid: �Ƿ���Ч
  -----------------------------------------------------------------------------}

  sSQL_NewTruckLog = 'Create Table $Table(R_ID $Inc, T_ID varChar(15),' +
       'T_Truck varChar(15),T_Status Char(1), T_NextStatus Char(1),' +
       'T_IsHK Char(1),' +
       'T_InTime DateTime, T_InMan varChar(32),' +
       'T_OutTime DateTime, T_OutMan varChar(32),' +
       'T_BFPTime DateTime, T_BFPMan varChar(32), T_BFPValue $Float Default 0,' +
       'T_BFMTime DateTime, T_BFMMan varChar(32), T_BFMValue $Float Default 0,' +
       'T_FHSTime DateTime, T_FHETime DateTime, T_FHLenth Integer,' +
       'T_FHMan varChar(32), T_FHValue Decimal(15,5),' +
       'T_ZTTime DateTime, T_ZTMan varChar(32),' +
       'T_ZTValue $Float,T_ZTCount Integer, T_ZTDiff Integer)';
  {-----------------------------------------------------------------------------
   ������־:TruckLog
   *.T_ID:��¼���
   *.T_Truck:���ƺ�
   *.T_Status,T_NextStatus:״̬
   *.T_IsHK: �Ƿ�Ͽ�
   *.T_InTime,T_InMan:����ʱ��,������
   *.T_OutTime,T_OutMan:����ʱ��,������
   *.T_BFPTime,T_BFPMan,T_BFPValue:Ƥ��ʱ��,������,Ƥ��
   *.T_BFMTime,T_BFMMan,T_BFMValue:ë��ʱ��,������,ë��
   *.T_FHSTime,T_FHETime,
     T_FHLenth,T_FHMan,T_FHValue:��ʼʱ��,����ʱ��,ʱ��������,�Ż���
   *.T_ZTTime,T_ZTMan,
     T_ZTValue,T_ZTCount,T_ZTDiff:ջ̨ʱ��,������,�����,����,����
  -----------------------------------------------------------------------------}

  sSQL_NewCustomer = 'Create Table $Table(C_ID varChar(32), C_Name varChar(80),' +
       'C_PY varChar(80), C_Phone varChar(20), C_Saler varChar(32),' +
       'C_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   �ͻ���: Customer
   *.C_ID: ���
   *.C_Name: ����
   *.C_PY: ƴ����д
   *.C_Phone: ��ϵ��ʽ
   *.C_Saler: ҵ��Ա
   *.C_Memo: ��ע
  -----------------------------------------------------------------------------}

  sSQL_NewMaterails = 'Create Table $Table(M_ID varChar(32), M_Name varChar(80),' +
       'M_PY varChar(80), M_Unit varChar(20), M_Price $Float,' +
       'M_PrePValue Char(1), M_PrePTime Integer, M_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ���ϱ�: Materails
   *.M_ID: ���
   *.M_Name: ����
   *.M_PY: ƴ����д
   *.M_Unit: ��λ
   *.M_PrePValue: Ԥ��Ƥ��
   *.M_PrePTime: Ƥ��ʱ��(��)
   *.M_Memo: ��ע
  -----------------------------------------------------------------------------}

  sSQL_NewPoundLog = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Type varChar(1), P_Order varChar(20), P_Card varChar(16),' +
       'P_Bill varChar(20), P_Truck varChar(15), P_CusID varChar(32),' +
       'P_CusName varChar(80), P_MID varChar(32),P_MName varChar(80),' +
       'P_MType varChar(10), P_LimValue $Float,' +
       'P_PValue $Float, P_PDate DateTime, P_PMan varChar(32), ' +
       'P_MValue $Float, P_MDate DateTime, P_MMan varChar(32), ' +
       'P_FactID varChar(32), P_Station varChar(10), P_MAC varChar(32),' +
       'P_Direction varChar(10), P_PModel varChar(10), P_Status Char(1),' +
       'P_Valid Char(1), P_PrintNum Integer Default 1,' +
       'P_DelMan varChar(32), P_DelDate DateTime)';
  {-----------------------------------------------------------------------------
   ������¼: Materails
   *.P_ID: ���
   *.P_Type: ����(����,��Ӧ,��ʱ)
   *.P_Order: ������
   *.P_Bill: ������
   *.P_Truck: ����
   *.P_CusID: �ͻ���
   *.P_CusName: ������
   *.P_MID: ���Ϻ�
   *.P_MName: ������
   *.P_MType: ��,ɢ��
   *.P_LimValue: Ʊ��
   *.P_PValue,P_PDate,P_PMan: Ƥ��
   *.P_MValue,P_MDate,P_MMan: ë��
   *.P_FactID: �������
   *.P_Station,P_MAC: ��վ��ʶ
   *.P_Direction: ��������(��,��)
   *.P_PModel: ����ģʽ(��׼,��Ե�)
   *.P_Status: ��¼״̬
   *.P_Valid: �Ƿ���Ч
   *.P_PrintNum: ��ӡ����
   *.P_DelMan,P_DelDate: ɾ����¼
  -----------------------------------------------------------------------------}

  sSQL_NewZTLines = 'Create Table $Table(R_ID $Inc, Z_ID varChar(15),' +
       'Z_Name varChar(32), Z_StockNo varChar(20), Z_Stock varChar(80),' +
       'Z_StockType Char(1), Z_PeerWeight Integer,' +
       'Z_RdID varChar(32), Z_RdIP varChar(32), Z_RdPort Integer,' +
       'Z_CtrlID varChar(32), Z_CtrlIP varChar(32), Z_CtrlPort Integer,' +
       'Z_CtrlLine Integer,' +
       'Z_QueueMax Integer, Z_VIPLine Char(1), Z_Valid Char(1), Z_Index Integer)';
  {-----------------------------------------------------------------------------
   װ��������: ZTLines
   *.R_ID: ��¼��
   *.Z_ID: ���
   *.Z_Name: ����
   *.Z_StockNo: Ʒ�ֱ��
   *.Z_Stock: Ʒ��
   *.Z_StockType: ����(��,ɢ)
   *.Z_PeerWeight: ����
   *.Z_RdID,Z_RdIP,Z_RdPort: ������
   *.Z_CtrlID,Z_CtrlIP,Z_CtrlPort,Z_CtrlLine: ������  
   *.Z_QueueMax: ���д�С
   *.Z_VIPLine: VIPͨ��
   *.Z_Valid: �Ƿ���Ч
   *.Z_Index: ˳������
  -----------------------------------------------------------------------------}

  sSQL_NewZTTrucks = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15),' +
       'T_StockNo varChar(20), T_Stock varChar(80), T_Type Char(1),' +
       'T_Line varChar(15), T_Index Integer, ' +
       'T_InTime DateTime, T_InFact DateTime, T_InQueue DateTime,' +
       'T_InLade DateTime, T_VIP Char(1), T_Valid Char(1), T_Bill varChar(15),' +
       'T_Value $Float, T_PeerWeight Integer, T_Total Integer Default 0,' +
       'T_Normal Integer Default 0, T_BuCha Integer Default 0)';
  {-----------------------------------------------------------------------------
   ��װ������: ZTTrucks
   *.R_ID: ��¼��
   *.T_Truck: ���ƺ�
   *.T_StockNo: Ʒ�ֱ��
   *.T_Stock: Ʒ������
   *.T_Type: Ʒ������(D,S)
   *.T_Line: ���ڵ�
   *.T_Index: ˳������
   *.T_InTime: ���ʱ��
   *.T_InFact: ����ʱ��
   *.T_InQueue: ����ʱ��
   *.T_InLade: ���ʱ��
   *.T_VIP: ��Ȩ
   *.T_Bill: �ᵥ��
   *.T_Valid: �Ƿ���Ч
   *.T_Value: �����
   *.T_PeerWeight: ����
   *.T_Total: ��װ����
   *.T_Normal: ��������
   *.T_BuCha: �������
  -----------------------------------------------------------------------------}

  sSQL_ZTTruckLog = 'Create Table $Table(R_ID $Inc, L_Truck varChar(15),' +
       'L_Line varChar(15), L_Bill varChar(15), L_Total Integer,' +
       'L_Normal Integer, L_BuCha Integer)';
  {-----------------------------------------------------------------------------
   ջ̨װ����¼: ZTTruckLog
   *.R_ID: ��¼��
   *.L_Truck: ���ƺ�
   *.L_Line: ���ڵ�
   *.L_Bill: �ᵥ��
   *.L_Total: ��װ����
   *.L_Normal: ��������
   *.L_BuCha: �������
  -----------------------------------------------------------------------------}

  sSQL_NewXSOrder = 'Create Table $Table(R_ID $Inc, BillID varChar(20), ' +
       'VBELN varChar(20), AUART varChar(8), BEZEI varChar(40), ' +
       'VKORG varChar(8), VTEXT varChar(40), KUNNR_AG varChar(20), ' +
       'NAME1_AG varChar(70), KUNNR_WE varChar(20), NAME1_WE varChar(70), ' +
       'VBELN_CT varChar(20), LIFNR_CT varChar(20), OTHER_MG varChar(500),' +
       'POSNR varChar(12),  WERKS varChar(8),  NAME1 varChar(60),' +
       'VSTEL varChar(8),  VTEXT_1 varChar(60),  LGORT varChar(8),' +
       'LGOBE varChar(32), MATNR varChar(36), ARKTX varChar(80),' +
       'MVGR1 varChar(6), BEZEI_1 varChar(80), KWMENG $Float, RFMNG $Float,' +
       'WTSL $Float, KYSL $Float)';
  {-----------------------------------------------------------------------------
   ���۶�����: OrderXS
    VBELN    : ���۶�����
    AUART    : ����ƾ֤����
    BEZEI    : ��������
    VKORG    : ������֯
    VTEXT    : ������֯����
    KUNNR_AG : �۴﷽
    NAME1_AG : �۴﷽����
    KUNNR_WE : �ʹ﷽
    NAME1_WE : �ʹ﷽����
    VBELN_CT : �����ͬ��
    LIFNR_CT : ���乩Ӧ��
    OTHER_MG : ������Ϣ

    POSNR    : ������Ŀ��
    WERKS    : ����
    NAME1    : ��������
    VSTEL    : װ�˵�
    VTEXT_1  : װ�˵�����
    LGORT    : ���ص�
    LGOBE    : ���ص�����
    MATNR    : ���Ϻ�
    ARKTX    : ��������
    MVGR1    : ������1
    BEZEI_1  : ��������
    KWMENG   : �ۼƶ�������
    RFMNG    : ��������
    WTSL     : δ������
    KYSL     : ��������
  -----------------------------------------------------------------------------}

  sSQL_NewZCOrder = 'Create Table $Table(R_ID $Inc, BillID varChar(20), ' +
       'VBELN varChar(20), BSART varChar(8), BATXT varChar(40),' +
       'LIFNR varChar(20), NAME1 varChar(70), KUNNR_WE varChar(20),' +
       'NAME1_WE varChar(70), VBELN_CT varChar(20), LIFNR_CT varChar(20),' +
       'OTHER_MG varChar(500), POSNR varChar(10),' +
       'WERKS varChar(8), NAME1_1 varChar(60), VSTEL varChar(8),' +
       'VTEXT varChar(60), LGORT varChar(8), LGOBE varChar(32),' +
       'WERKS_J varChar(8), NAME1_J varChar(60), MATNR varChar(36),' +
       'TXZ01 varChar(80), MENGE $Float, YTSL $Float,' +
       'WTSL $Float)';
  {-----------------------------------------------------------------------------
   ת��������: OrderZC
    VBELN    : ת��������
    BSART    : ƾ֤����
    BATXT    : ƾ֤���͵ļ������
    LIFNR    : ��Ӧ��
    NAME1    : ��Ӧ������
    KUNNR_WE : �ʹ﷽
    NAME1_WE : �ʹ﷽����
    VBELN_CT : �����ͬ��
    LIFNR_CT : ���乩Ӧ��
    OTHER_MG : ������Ϣ

    POSNR    : ת��������Ŀ��
    WERKS    : ����
    NAME1_1  : ��������
    VSTEL    : װ�˵�/���յ�
    VTEXT    : װ�˵�����
    LGORT    : ���ص�
    LGOBE    : ���ص�����
    WERKS_J  : ��������
    NAME1_J  : ������������
    MATNR    : ���Ϻ�
    TXZ01    : ��������
    MENGE    : ��������
    YTSL     : ��������
    WTSL     : δ������
  -----------------------------------------------------------------------------}
  
function CardStatusToStr(const nStatus: string): string;
//�ſ�״̬
function TruckStatusToStr(const nStatus: string): string;
//����״̬

implementation

//------------------------------------------------------------------------------
//Desc: ��nStatusתΪ�ɶ�����
function CardStatusToStr(const nStatus: string): string;
begin
  if nStatus = sFlag_CardIdle then Result := '����' else
  if nStatus = sFlag_CardUsed then Result := '����' else
  if nStatus = sFlag_CardLoss then Result := '��ʧ' else
  if nStatus = sFlag_CardInvalid then Result := 'ע��' else Result := 'δ֪';
end;

//Desc: ��nStatusתΪ��ʶ�������
function TruckStatusToStr(const nStatus: string): string;
begin
  if nStatus = sFlag_TruckIn then Result := '����' else
  if nStatus = sFlag_TruckOut then Result := '����' else
  if nStatus = sFlag_TruckBFP then Result := '��Ƥ��' else
  if nStatus = sFlag_TruckBFM then Result := '��ë��' else
  if nStatus = sFlag_TruckSH then Result := '�ͻ���' else
  if nStatus = sFlag_TruckFH then Result := '�ŻҴ�' else
  if nStatus = sFlag_TruckZT then Result := 'ջ̨' else Result := 'δ����';
end;

//------------------------------------------------------------------------------
//Desc: ���ϵͳ����
procedure AddSysTableItem(const nTable,nNewSQL: string);
var nP: PSysTableItem;
begin
  New(nP);
  gSysTableList.Add(nP);

  nP.FTable := nTable;
  nP.FNewSQL := nNewSQL;
end;

//Desc: ϵͳ��
procedure InitSysTableList;
begin
  gSysTableList := TList.Create;

  AddSysTableItem(sTable_SysDict, sSQL_NewSysDict);
  AddSysTableItem(sTable_ExtInfo, sSQL_NewExtInfo);
  AddSysTableItem(sTable_SysLog, sSQL_NewSysLog);
  AddSysTableItem(sTable_BaseInfo, sSQL_NewBaseInfo);

  AddSysTableItem(sTable_SerialBase, sSQL_NewSerialBase);
  AddSysTableItem(sTable_SerialStatus, sSQL_NewSerialStatus);
  AddSysTableItem(sTable_StorLocation, sSQL_NewStorLocation);
  AddSysTableItem(sTable_StockMatch, sSQL_NewStockMatch);

  AddSysTableItem(sTable_Bill, sSQL_NewBill);
  AddSysTableItem(sTable_BillInfo, sSQL_NewBillInfo);
  AddSysTableItem(sTable_OrderXS, sSQL_NewXSOrder);
  AddSysTableItem(sTable_OrderZC, sSQL_NewZCOrder);
  AddSysTableItem(sTable_Card, sSQL_NewCard);

  AddSysTableItem(sTable_Truck, sSQL_NewTruck);
  AddSysTableItem(sTable_TruckLog, sSQL_NewTruckLog);
  AddSysTableItem(sTable_Customer, sSQL_NewCustomer);
  AddSysTableItem(sTable_Materails, sSQL_NewMaterails);
  AddSysTableItem(sTable_PoundLog, sSQL_NewPoundLog);
  AddSysTableItem(sTable_PoundBak, sSQL_NewPoundLog);

  AddSysTableItem(sTable_ZTLines, sSQL_NewZTLines);
  AddSysTableItem(sTable_ZTTrucks, sSQL_NewZTTrucks);
  AddSysTableItem(sTable_ZTTruckLog, sSQL_ZTTruckLog);

  AddSysTableItem(sTable_Message, sSQL_NewMessage);                  // 20130613
  AddSysTableItem(sTable_MTime, sSQL_NewMTime);                      // 20130613
  AddSysTableItem(sTable_MUser, sSQL_NewMUser);                      // 20130613
  AddSysTableItem(sTable_Template, sSQL_NewMTemplate);               // 20130808
  AddSysTableItem(sTable_Definition, sSQL_NewMDefinition);           // 20130808
end;

//Desc: ����ϵͳ��
procedure ClearSysTableList;
var nIdx: integer;
begin
  for nIdx:= gSysTableList.Count - 1 downto 0 do
  begin
    Dispose(PSysTableItem(gSysTableList[nIdx]));
    gSysTableList.Delete(nIdx);
  end;

  FreeAndNil(gSysTableList);
end;

initialization
  InitSysTableList;
finalization
  ClearSysTableList;
end.


