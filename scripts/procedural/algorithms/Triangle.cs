using System.Collections.Generic;

public class Triangle
{
    private readonly Point pointA;
    private readonly Point pointB;
    private readonly Point pointC;

    public readonly HashSet<Edge> edges;

    private readonly float circumcenterX;
    private readonly float circumcenterY;
    private readonly float circumRadiusSquared;

    public Triangle(Point pointA, Point pointB, Point pointC)
    {
        // hashing depends on the orderliness of a, b, c
        if (pointA < pointB)
        {
            if (pointB < pointC)
            {
                // a, b, c
                this.pointA = pointA;
                this.pointB = pointB;
                this.pointC = pointC;
            }
            else if (pointA < pointC)
            {
                // a, c, b
                this.pointA = pointA;
                this.pointB = pointC;
                this.pointC = pointB;
            }
            else
            {
                // c, a, b
                this.pointA = pointC;
                this.pointB = pointA;
                this.pointC = pointB;
            }
        }
        else if (pointA < pointC)
        {
            // b, a, c
            this.pointA = pointB;
            this.pointB = pointA;
            this.pointC = pointC;
        }
        else if (pointB < pointC)
        {
            // b, c, a
            this.pointA = pointB;
            this.pointB = pointC;
            this.pointC = pointA;
        }
        else
        {
            // c, b, a
            this.pointA = pointC;
            this.pointB = pointA;
            this.pointC = pointB;
        }

        edges = new HashSet<Edge>
        {
            new Edge(this.pointA, this.pointB),
            new Edge(this.pointB, this.pointC),
            new Edge(this.pointA, this.pointC)
        };

        float D = (pointA.x * (pointB.y - pointC.y) +
                    pointB.x * (pointC.y - pointA.y) +
                    pointC.x * (pointA.y - pointB.y)) * 2;
        float x = (pointA.x * pointA.x + pointA.y * pointA.y) * (pointB.y - pointC.y) +
                (pointB.x * pointB.x + pointB.y * pointB.y) * (pointC.y - pointA.y) +
                (pointC.x * pointC.x + pointC.y * pointC.y) * (pointA.y - pointB.y);
        float y = (pointA.x * pointA.x + pointA.y * pointA.y) * (pointC.x - pointB.x) +
                (pointB.x * pointB.x + pointB.y * pointB.y) * (pointA.x - pointC.x) +
                (pointC.x * pointC.x + pointC.y * pointC.y) * (pointB.x - pointA.x);

        circumcenterX = x / D;
        circumcenterY = y / D;
        float dx = pointA.x - circumcenterX;
        float dy = pointA.y - circumcenterY;
        circumRadiusSquared = dx * dx + dy * dy;
    }

    public override bool Equals(object obj)
    {
        return obj is Triangle other && pointA == other.pointA && pointB == other.pointB && pointC == other.pointC;
    }

    public override int GetHashCode()
    {
        var hashCode = 1474027755;
        hashCode = hashCode * -1521134295 + pointA.GetHashCode();
        hashCode = hashCode * -1521134295 + pointB.GetHashCode();
        hashCode = hashCode * -1521134295 + pointC.GetHashCode();
        return hashCode;
    }

    public override string ToString()
    {
        return $"Triangle({pointA}, {pointB}, {pointC})";
    }

    public bool HasEdge(Edge edge)
    {
        return edges.Contains(edge);
    }

    private bool HasVertex(Point point)
    {
        return pointA == point || pointB == point || pointC == point;
    }

    public bool HasVertexFrom(Triangle triangle)
    {
        return HasVertex(triangle.pointA) || HasVertex(triangle.pointB) || HasVertex(triangle.pointC);
    }

    public bool CircumCircleContains(Point point)
    {
        float dx = point.x - circumcenterX;
        float dy = point.y - circumcenterY;
        float distance2 = dx * dx + dy * dy;
        return distance2 < circumRadiusSquared;
    }
}
