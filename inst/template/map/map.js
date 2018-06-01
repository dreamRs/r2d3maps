
// D3 maps


r2d3.onRender(function(json, svg, width, height, options) {

  var projection = d3.geoMercator();

  var path = d3.geoPath()
      .projection(projection);

  svg.attr("width", width)
     .attr("height", height);

  var states = topojson.feature(json, json.objects.states);

  projection
      .scale(1)
      .translate([0, 0]);

  var b = path.bounds(states),
      s = 0.95 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height),
      t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2];

  projection
      .scale(s)
      .translate(t);

  svg.append("path")
      .datum(states)
      .attr("class", "feature")
      .attr("d", path);

  svg.append("path")
      .datum(topojson.mesh(json, json.objects.states, function(a, b) { return a !== b; }))
      .attr("class", "mesh")
      .attr("d", path);
});
