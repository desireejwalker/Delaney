using System.Collections.Generic;

public static class Kruskal
{
    public static List<Edge> MinimumSpanningTree(IEnumerable<Edge> graph)
    {
        List<Edge> ans = new List<Edge>();

        List<Edge> edges = new List<Edge>(graph);
        edges.Sort(Edge.LengthComparison);

        HashSet<Point> points = new HashSet<Point>();
        foreach (var edge in edges)
        {
            points.Add(edge.pointA);
            points.Add(edge.pointB);
        }

        Dictionary<Point, Point> parents = new Dictionary<Point, Point>();
        foreach (var point in points)
            parents[point] = point;

        Point UnionFind(Point x)
        {
            if (parents[x] != x)
                parents[x] = UnionFind(parents[x]);
            return parents[x];
        }

        foreach (var edge in edges)
        {
            var x = UnionFind(edge.pointA);
            var y = UnionFind(edge.pointB);
            if (x != y)
            {
                ans.Add(edge);
                parents[x] = y;
            }
        }

        return ans;
    }
}
