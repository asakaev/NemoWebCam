unit Fish;

interface

// ExtCtrls Ч TImage
// Graphics Ч TBitmap
uses ExtCtrls, Graphics, Classes, Math, Dialogs;

Type
  TFish = class(TImage) // наследуем от TImage Ч интересует функционал предка

  private

  public
    x, y: real; // координаты рыбки
    PicNum: integer; // номер фрейма дл€ рисовани€
    angle: real; // направление, куда рыба плывЄт

    // ƒиректива Override определ€ет метод класса как замена так же названного
    // метода в родительском классе.
    constructor Create(AOwner: TComponent); override;
end;

implementation

constructor TFish.Create(AOwner: TComponent);
begin
  // Inherited Ч вызов родительского класса конструктора
  // или метода деструктора
  Inherited Create(AOwner);

  // начальные значени€ при создании объекта
  x := random(500);
  y := random(500);
  angle := random(350);

end;

end.
