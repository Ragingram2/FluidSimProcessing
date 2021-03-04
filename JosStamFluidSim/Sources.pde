public abstract class Source
{
      private Fluid fluid;

      public Source(Fluid _fluid)
      {
          fluid = _fluid;
      }

      public abstract void Draw();
}