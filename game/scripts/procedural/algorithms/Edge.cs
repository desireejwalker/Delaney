using Godot;

public class Edge
{
    public readonly Point pointA;
    public readonly Point pointB;

    private float length = -1;
    public float Length
    {
        get
        {
            if (length < 0)
            {
                float dx = pointA.x - pointB.x;
                float dy = pointA.y - pointB.y;
                length = Mathf.Sqrt(dx * dx + dy * dy);
            }
            return length;
        }
    }

    public Edge(Point pointA, Point pointB)
    {
        if (pointA == pointB)
        {
            throw new DuplicatePointException(pointA, pointB);
        }
        else if (pointA < pointB)
        {
            this.pointA = pointA;
            this.pointB = pointB;
        }
        else
        {
            this.pointA = pointB;
            this.pointB = pointA;
        }
    }

    public override bool Equals(object obj)
    {
        return obj is Edge other && pointA == other.pointA && pointB == other.pointB;
    }

    public override int GetHashCode()
    {
        var hashCode = 2118541809;
        hashCode = hashCode * -1521134295 + pointA.GetHashCode();
        hashCode = hashCode * -1521134295 + pointB.GetHashCode();
        return hashCode;
    }

    public override string ToString()
    {
        return $"Edge({pointA}, {pointB})";
    }

    public static int LengthComparison(Edge x, Edge y)
    {
        float lx = x.Length;
        float ly = y.Length;
        if (Mathf.IsEqualApprox(lx, ly))
        {
            return 0;
        }
        else if (lx > ly)
        {
            return 1;
        }
        else
        {
            return -1;
        }
    }
}
