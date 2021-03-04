public class RectSource extends Source
{

  private float widthRes;
  private float heightRes;
  private int sWidth;
  private int sHeight;
  private int sourceAmount = 10;
  private PVector position;


  public RectSource(Fluid _fluid, PVector _pos, int _w, int _h, int _sourceAmount)
  {
    super(_fluid);
    widthRes = (_fluid.GetSize() / (float)width);
    heightRes = (_fluid.GetSize() / (float)height);
    position = _pos;
    sWidth = _w;
    sHeight = _h;
    sourceAmount = _sourceAmount;
  }

  public void Draw()
  {
    for (int i = - sWidth; i <= sHeight; i++)
    {
      for (int j =- sHeight; j <= sHeight; j++) 
      {
        super.fluid.AddDensity((int)(position.x + (i * widthRes)), (int)(position.y + (j * heightRes)), sourceAmount);
      }
    }
  }
}
