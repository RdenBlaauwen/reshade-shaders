# Softening test
TSMAA softening: weaker effect, but more performant
HQAA: stronger effect, more configurable, bgger performance impact

todo: compare the two methods and merge them if possible
## Performance
no softening: 2.74 - 2.82
TSMAA softening: 3.03 - 2.18
HQAA softening: 3.35 - 3.51

# Lessons
## Performance of maxComp
This following code:
```
/**
 * Finds the greatest component of an RGB coded color.
 * 
 * @param float3 rgb a color
 * @return float the greates component found in the input color
 */
float maxComp(float3 rgb){
	return max(rgb.r, max(rgb.g, rgb.b));
}
```
Was actually SLOWER than:
```
float maxComp(float2 rg)
{
return max(rg.r, rg.g);
}
float maxComp(float3 rgb)
{
return max(maxComp(rgb.rg), rgb.b);
}
```
I have no idea why.
## Performance of corner count
THis "optimized" corner counting code:
```
float corners = (edgeData.r + edgeData.b) * (edgeData.g + edgeData.a);
```
somehow didn't improve performance vs the naive approach, which is:
```
float corners = saturate(edgeData.r + edgeData.g - 1.0) 
	+ saturate(edgeData.g + edgeData.b - 1.0) 
	+ saturate(edgeData.b + edgeData.a - 1.0) 
	+ saturate(edgeData.a + edgeData.r - 1.0);
```
