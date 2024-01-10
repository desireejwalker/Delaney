using Godot;

public class Point
{
    public readonly int x;
    public readonly int y;

    public Point(int x, int y)
    {
        this.x = x;
        this.y = y;
    }
    public Point(Vector2I position)
    {
        this.x = position.X;
        this.y = position.Y;
    }

    public Vector2 ToVector2()
    {
        return new Vector2(x, y);
    }

    public override bool Equals(object obj)
    {
        return obj is Point other && x == other.x && y == other.y;
    }

    public override int GetHashCode()
    {
        var hashCode = 1502939027;
        hashCode = hashCode * -1521134295 + x.GetHashCode();
        hashCode = hashCode * -1521134295 + y.GetHashCode();
        return hashCode;
    }

    public override string ToString()
    {
        return $"Point({this.x}, {this.y})";
    }

    public static bool operator <(Point lhs, Point rhs)
    {
        return (lhs.x < rhs.x) || ((lhs.x == rhs.x) && (lhs.y < rhs.y));
    }

    public static bool operator >(Point lhs, Point rhs)
    {
        return (lhs.x > rhs.x) || ((lhs.x == rhs.x) && (lhs.y > rhs.y));
    }
}
