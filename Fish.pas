unit Fish;

interface

// ExtCtrls � TImage
// Graphics � TBitmap
uses ExtCtrls, Graphics, Classes, Math, Dialogs;

Type
  TFish = class(TImage) // ��������� �� TImage � ���������� ���������� ������

  private

  public
    x, y: real; // ���������� �����
    PicNum: integer; // ����� ������ ��� ���������
    angle: real; // �����������, ���� ���� �����

    // ��������� Override ���������� ����� ������ ��� ������ ��� �� ����������
    // ������ � ������������ ������.
    constructor Create(AOwner: TComponent); override;
end;

implementation

constructor TFish.Create(AOwner: TComponent);
begin
  // Inherited � ����� ������������� ������ ������������
  // ��� ������ �����������
  Inherited Create(AOwner);

  // ��������� �������� ��� �������� �������
  x := random(500);
  y := random(500);
  angle := random(350);

end;

end.
