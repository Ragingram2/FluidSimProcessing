public class CandleSource extends Source
{

  private float swayRange = PI/16;
  private PVector position;
  private int radius = 15;
  private int forceRadius;
  private int sourceAmount = 10;
  private float t = 0;
  private float angle;
  private PVector noiseVec = new PVector(0, -1);
  private PVector vec;

  public CandleSource(Fluid _fluid, PVector _pos, int _radius, int _sourceAmount)
  {
    super(_fluid);
    position = _pos;
    radius = _radius;
    sourceAmount = _sourceAmount;
  }

  public void Draw()
  {
    t+=0.1f;
    angle = noise(t) * swayRange;
    angle -= ((PI/2)+swayRange/2);
    noiseVec = PVector.fromAngle(angle);
    vec = noiseVec.normalize();

    //DrawCandlde
    for (int y=-radius; y<=radius; y++)
      for (int x=-radius; x<=radius; x++)
        if (x*x+y*y <= radius*radius)
          super.fluid.AddDensity(position.x+x, position.y+y, sourceAmount);

    forceRadius = (int)(radius*.7f);
    for (int y=-forceRadius; y<=forceRadius; y++)
      for (int x=-forceRadius; x<=forceRadius; x++)
        if (x*x+y*y <= forceRadius*forceRadius)
          super.fluid.AddVelocity(position.x+x, position.y+y, vec.x, vec.y );
  }
}
