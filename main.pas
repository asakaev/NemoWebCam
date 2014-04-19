unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Fish, math, StdCtrls, ShellAPI;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Timer2: TTimer;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);

  private
    angle,x_pos,y_pos: real;
    // �� ����� ���� �� ����� ������, ��*
    Fish: Array[0..11] of TFish;
    MainFish: TFish;
    back:TBitmap; // ���
    backBuf:TBitmap;
    FishPicTemp1:TBitmap; // ���� ������ �����
    FishPic1: Array[0..12] of TBitmap; // ���� ������ ����� �� ������ (12)
    MainFishPicTemp: TBitmap; // ���� ������� ����
    MainFishPic:Array[0..12] of TBitmap; // ���� ������� ���� �� ������
    FishCount: integer;
    Score: integer;
    ScoreTemp, Level: integer;
    speed: real;
    procedure XYGen();
    procedure CreateFishes();
    procedure FishDraw();
    procedure PicsLoadChop();
    procedure KillFish();
    procedure LevelUp();

  public
    // ������� ������ � ������
    bmp:TBitmap;
    showWebCam: boolean;
    procedure ShowHideCam();
    procedure FindXY();
    procedure CamInit();
    procedure FakeBuffer();
    procedure WebCamStart();
end;

// ��� ��������� ������ ������
type
  TcPanel = class(TPanel)
public
  property Canvas;
end;

// ��� ������
const WM_CAP_START = WM_USER;
WM_CAP_STOP = WM_CAP_START + 68;
WM_CAP_DRIVER_CONNECT = WM_CAP_START + 10;
WM_CAP_DRIVER_DISCONNECT = WM_CAP_START + 11;
WM_CAP_SAVEDIB = WM_CAP_START + 25;
WM_CAP_GRAB_FRAME = WM_CAP_START + 60;
WM_CAP_SEQUENCE = WM_CAP_START + 62;
WM_CAP_FILE_SET_CAPTURE_FILEA = WM_CAP_START + 20;

// ��� ������
function capCreateCaptureWindowA(lpszWindowName : PCHAR;
dwStyle : longint;
x : integer;
y : integer;
nWidth : integer;
nHeight : integer;
ParentWin : HWND;
nId : integer): HWND;
stdcall external 'AVICAP32.DLL';

var
  Form1: TForm1;
  // ��� ������
  hWndDC: HDC;
  Panel: TcPanel;
  hWndC: THandle;
  Bt:BITMAPINFO; // ����� ��� ����� ����������

implementation
{$R *.dfm}

procedure TForm1.PicsLoadChop();
var
i:Integer;

begin
  FishPicTemp1 := TBitmap.Create;
  FishPicTemp1.LoadFromFile('fish1.bmp');

  MainFishPicTemp := TBitmap.Create;
  MainFishPicTemp.LoadFromFile('mainFish.bmp');

  for i:=0 to 11 do
  begin
    // ����� ���� ��� 1�� ���� ---
    FishPic1[i]:=TBitmap.Create();
    FishPic1[i].Width:=70;
    FishPic1[i].Height:=70;

    FishPic1[i].Canvas.CopyRect(Rect(0,0,70,70),
    FishPicTemp1.Canvas,Rect(i*70,0,i*70+70,70));

    // ������ ������������ � �������� ����, ������� ����� ����������
    FishPic1[i].Transparent:=true;
    FishPic1[i].TransParentColor := FishPicTemp1.Canvas.Pixels[1,1];

    // ����� ���� ��� �� ---
    MainFishPic[i] := TBitmap.Create();
    MainFishPic[i].Width:=70;
    MainFishPic[i].Height:=70;

    MainFishPic[i].Canvas.CopyRect(Rect(0,0,70,70),
    MainFishPicTemp.Canvas,Rect(i*70,0,i*70+70,70));

    // ������ ������������ � �������� ����, ������� ����� ����������
    MainFishPic[i].Transparent:=true;
    //MainFishPic[i].TransParentColor := FishPicTemp1.Canvas.Pixels[1,1];
  end;
end;


procedure TForm1.XYGen();
var
  picNomer:integer;
  dx,dy:real;
  i: integer;

begin
  for i := 0 to 1 do
  begin
    Fish[i].PicNum := Trunc( (360-Fish[i].angle) / 30); // ����������� �����
    dx := cos(DegToRad(Fish[i].angle))*speed;
    dy := sin(DegToRad(Fish[i].angle))*speed;

    // ������� ����� �� ���� ����� � ���������� � ������ �������
    if(Fish[i].x > (Form1.Width+70)) then Fish[i].x := -70;
    if(Fish[i].x < -70) then Fish[i].x := Form1.Width+70;
    if(Fish[i].y > (Form1.Height+70)) then Fish[i].y := -70;
    if(Fish[i].y < -70) then Fish[i].y := Form1.Height+70;

    // �������� ����������� ���� �����
    if random(2)=1 then
    begin
      Fish[i].angle:=Fish[i].angle+5;
      if(Fish[i].angle>=360)
      then Fish[i].angle:=0;
    end
    else
    begin
      Fish[i].angle:=Fish[i].angle-5;
      if(Fish[i].angle<0)
      then Fish[i].angle:=359;
    end;

    Fish[i].x := Fish[i].x + dx;
    Fish[i].y := Fish[i].y + dy;
  end;
end;


procedure TForm1.CreateFishes;
var
  i: Integer;

begin
  MainFish := TFish.Create(Owner); // ������ ������� ����

  for i := 0 to 1 do
  begin
    Fish[i] := TFish.Create(Owner); // � �����
  end;

end;


procedure TForm1.FishDraw();
var
  i: Integer;
begin
  // � ����� ������ ���� ��� �������������� ������� ����� ��
  backBuf.Canvas.Draw(0,0, back); // ������ ������ ����

  for i := 0 to 1 do
  begin
    // ����� ������
    backBuf.Canvas.Draw(Trunc(Fish[i].x),
    Trunc(Fish[i].y), FishPic1[Fish[i].PicNum] );
  end;

  // ������ ��
  backBuf.Canvas.Draw(Trunc(MainFish.x),
  Trunc(MainFish.y), MainFishPic[MainFish.PicNum] );

  Form1.Canvas.Draw(0,0,backBuf); // ������� ��, ��� ����������

end;


// ��� �������� �����
procedure TForm1.FormCreate(Sender: TObject);
begin
  speed:=4; // �������� ��� ��������� ��������
  //FishCount := 1; // ���������� ���
  Score := 0; // ���� �����
  ScoreTemp := Score;
  Level := 1;

  // ������ ������
  back:=TBitmap.Create();
  // ��������� �������� ��� ����
  back.LoadFromFile('backg.bmp');
  // ��������� ������� ����� ��� ������� �����������
  Form1.Width := back.Width; // 1280
  Form1.Height := back.Height+21; // 720 + 21 �.�. ������ ��������
  back.Transparent:=false;

  // ��������� ���������� � � ������ (���� ��� �����)
  backBuf:=TBitmap.Create;
  backBuf.Width := back.Width;
  backBuf.Height := back.Height;

  CreateFishes(); // ������� ���-�������

  MainFish.x := 200;
  MainFish.y := 200;

  PicsLoadChop(); // ������ �������� ��������� � ����� ��


  // ����� ------------------------------
  // �������������� �����
  showWebCam := false;
  WebCamStart();
  FakeBuffer();
  CamInit();

end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  XYGen(); // ���������� ���������� ��� ���������� ����
  FishDraw();
  KillFish();
  levelup();
end;

procedure TForm1.KillFish();
var
  i:integer;

begin
  for i := 0 to 1 do
  begin
    // ���� ��� ����� � ��
    if ( abs(Fish[i].x - MainFish.x) < 70 ) and
    ( abs(Fish[i].y - MainFish.y) < 70 ) then
    begin
      // ���� ��������, �� ����������
      Fish[i].x := -70;
      Fish[i].y := -70;
      score:=score+1;

      // ������� Score, ���� ����� ��������
      Form1.Text := '';
      Form1.Text := 'Mysteries of the Deep Sea (Score: ' + IntToStr(score) + ' ' +
      'Level: ' + IntToStr(Level) + ')';
    end;
  end;
end;

procedure TForm1.LevelUp(); // ������ ���������� �������� � ������
begin
  if Score > ScoreTemp+5 then
  begin

    scoretemp:=score;
    Speed := Speed + 1;
    level:=level+1;
  end;

end;


// --- �����

// ��������� ������ ��� ����� � �������
// �� �������� ����� �� �������������� �� � ��������� ���
procedure TForm1.Timer2Timer(Sender: TObject);
begin
  //�������� �������� � ���������
  if hWndC <> 0 then SendMessage(hWndC, WM_CAP_GRAB_FRAME, 0, 0);

  // �������� ����� � ������� ����������
  FakeBuffer();
  FindXY();
end;


procedure TForm1.WebCamStart();
begin
  hWndC := 0; // �������

  // ���� ���� ������
  Panel:=TcPanel.Create(Self);
  Panel.Parent:=Form1;

  // ���������� ���������� ����� � ���� ������
  Panel.Left := 1280-320;
  Panel.Top := 720-240;

  // ������ ��������, ��������� ��� ������ �����
  Panel.Width := 320;
  Panel.Height := 240;
end;


procedure TForm1.ShowHideCam();
begin
  if showWebCam = false then
  begin
    // ���������� � ������� �����
    Panel.Left := 1280-320;
    Panel.Top := 720-240;
    showWebCam := true;
  end
  else
  begin
    Panel.Left := 1280;
    Panel.Top := 720;
    showWebCam := false;
  end;
end;


procedure TForm1.CamInit();
begin
  hWndC := capCreateCaptureWindowA('My Own Capture Window',
  WS_CHILD or WS_VISIBLE ,
  0,
  0,
  320, // ���
  240,
  Panel.Handle, // ������� � ���� ��������
  0); //������� ������� ��� ������ ���������� � ������� �������� =)

  // ���� ��� �������� ������� ������ �� ��������, �� �������� �������� � ���-������
  if hWndC <> 0 then
    SendMessage(hWndC, WM_CAP_DRIVER_CONNECT, 0, 0);  //�������� �������� � ���������

    // ������ ���������� � �����
    Bt.bmiHeader.biWidth := 320;
    Bt.bmiHeader.biHeight := 240;


end;

// ������� ��� ������ �����
procedure TForm1.FakeBuffer();
begin
    // ������ ���������� ������� �������
    bmp := TBitmap.Create;
    bmp.pixelformat:=pf24bit;
    bmp.Width := 320;
    bmp.Height:= 240;

    // �������� � �� ����������� � ������
    bmp.Canvas.CopyRect(Rect(0,0,320,240),
    Panel.Canvas,Rect(0,0,320,240));

    //Bmp.SaveToFile('MYFILE.BMP'); // ����� ������� � ����
end;


procedure TForm1.FindXY();
var
i,j: integer;
xUP, yUP, xDOWN, yDOWN: integer;
winUP, winDOWN: boolean;
dxMAIN, dyMAIN: integer; // ��������� ������ � ������

begin
  i := 0;
  j := 0;
  winUP := false;
  xUP:=0;
  yUP:=0;

  for i := 0 to 320-1 do
  begin
    for j := 0 to 240-1 do
    begin
      // ���� �������� ������ 200 � ������ � ������ ������ 50 �� ������
      if ( (GetRValue(bmp.canvas.Pixels[i,j]) > 200) and
      (GetGValue(bmp.canvas.Pixels[i,j]) < 50) and
      (GetBValue(bmp.canvas.Pixels[i,j]) < 50) )
      then
        begin
            xUP := i;
            yUP := j;
            winUp := true;
            break;
          //bmp.canvas.Pixels[i,j] := clBlack;
          //showmessage(IntToStr( GetBValue(bmp.canvas.Pixels[i,j]) ));
        end;
        if winUP = true then break;
    end;
  end;

  // ������������ ��� ������
  MainFish.x := xUP*4;
  MainFish.y := yUP*3;

  edit1.Text := FloatToStr(MainFish.x);
  edit2.Text := FloatToStr(MainFish.y);

  //edit1.Text := IntToStr(xUP*4);
  //edit2.Text := IntToStr(yUP*3);

end;

end.
