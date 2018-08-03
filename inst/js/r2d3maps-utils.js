
// r2d3maps utils

function init_map(json, width, height, proj) {
  var projection;
  if (proj == "Mercator") {
    projection = d3.geoMercator();
  } else if (proj == "ConicEqualArea") {
    projection = d3.geoConicEqualArea();
  } else if (proj == "NaturalEarth") {
    projection = d3.geoNaturalEarth1();
  } else {
    projection = d3.geoAlbers();
  }
  var path = d3.geoPath()
      .projection(projection);
  var states = topojson.feature(json, json.objects.states);
  projection
      .scale(1)
      .translate([0, 0]);
  var b = path.bounds(states),
      s = 0.90 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height),
      t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - (height*0.1) - s * (b[1][1] + b[0][1])) / 2];
  projection
      .scale(s)
      .translate(t);
  return {
    projection: projection,
    path: path,
    states: states
  };
}
