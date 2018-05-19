// D3 maps


r2d3.onRender(function(json, svg, width, height, options) {

  // utils
  // https://gist.github.com/mbostock/4699541
  function clicked(d) {
    if (active.node() === this) return reset();
    active.classed("active", false);
    active = d3.select(this).classed("active", true);
    var bounds = path.bounds(d),
        dx = bounds[1][0] - bounds[0][0],
        dy = bounds[1][1] - bounds[0][1],
        x = (bounds[0][0] + bounds[1][0]) / 2,
        y = (bounds[0][1] + bounds[1][1]) / 2,
        scale = 0.8 / Math.max(dx / width, dy / height),
        translate = [width / 2 - scale * x, height / 2 - scale * y];
    g.transition()
        .duration(750)
        .style("stroke-width", 1.5 / scale + "px")
        .attr("transform", "translate(" + translate + ")scale(" + scale + ")");
  }
  function reset() {
    active.classed("active", false);
    active = d3.select(null);
    g.transition()
        .duration(750)
        .style("stroke-width", "1.5px")
        .attr("transform", "");
  }
  // https://bl.ocks.org/iamkevinv/0a24e9126cd2fa6b283c6f2d774b69a2
  function zoomed() {
    g.style("stroke-width", 1.5 / d3.event.transform.k + "px");
    g.attr("transform", d3.event.transform); // updated for d3 v4
  }

  // global variables
  var map, projection, active = d3.select(null);

  // Projection
  if (options.projection == "Mercator") {
    projection = d3.geoMercator();
  } else if (options.projection == "ConicEqualArea") {
    projection = d3.geoConicEqualArea();
  } else if (options.projection == "NaturalEarth") {
    projection = d3.geoNaturalEarth1();
  } else {
    projection = d3.geoAlbers();
  }

  var path = d3.geoPath()
      .projection(projection);

  svg.attr("width", width)
     .attr("height", height);

  var states = topojson.feature(json, json.objects.states);

  // set projection
  projection
      .scale(1)
      .translate([0, 0]);

  // define bounding box & associated scale & transform
  var b = path.bounds(states),
      s = 0.9 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height),
      t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2];

  // re-project
  projection
      .scale(s)
      .translate(t);

  // Tooltip
  var div = d3.select("body").append("div")
    .attr("class", "tooltip")
    .style("opacity", 0);

  // main g
  var g = svg.append("g");

  // colors
  if (options !== null) {
    if (typeof options.colors != 'undefined') {

      // discrete colors
      if (options.colors.color_type == 'discrete') {

        var ordinal = d3.scaleOrdinal()
          .domain(options.colors.values)
          .range(options.colors.colors);
        map = g.append("g")
            .attr("class", "feature")
            .selectAll("path")
            .data(topojson.feature(json, json.objects.states).features)
            .enter().append("path")
              .attr("fill", function(d) { return ordinal(d.properties[options.colors.color_var]); })
              .attr("d", path);


        if (options.legend) {
          // Legend
          var gd = g.append("g")
              .attr("class", "legendThreshold")
              .attr("transform", "translate(10," + (height/2) + ")");
          gd.append("text")
              .attr("class", "caption")
              .attr("x", 0)
              .attr("y", -6)
              .text(options.legend_opts.title);
          var legend = d3.legendColor()
              .orient("vertical")
              .labels(function (d) { return options.colors.values[d.i]; })
              .cellFilter(function (d) { if (typeof d.label === 'undefined') { return false; } else { return true; } })
              .shapePadding(4)
              .scale(ordinal);
          g.select(".legendThreshold")
              .call(legend);
        }

      }

      // continuous colors
      if (options.colors.color_type == 'continuous') {

        var x = d3.scaleLinear()
                  .range([1, 200])
                  .domain(options.colors.range_var);
        var color = d3.scaleThreshold()
                      .domain(options.colors.range_col)
                      .range(options.colors.colors);

        if (options.legend) {
          var gc = svg.append("g")
            .attr("class", "key")
            .attr("transform", "translate(10," + (height - 30) + ")");

          gc.selectAll("rect")
            .data(color.range().map(function(d) {
                d = color.invertExtent(d);
                if (d[0] === null) d[0] = x.domain()[0];
                if (d[1] === null) d[1] = x.domain()[1];
                return d;
              }))
            .enter().append("rect")
              .attr("height", 8)
              .attr("x", function(d) { return x(d[0]); })
              .attr("width", function(d) { return x(d[1]) - x(d[0]); })
              .attr("fill", function(d) { return color(d[0]); });

          gc.append("text")
            .attr("class", "caption")
            .attr("x", 0)
            .attr("y", -6)
            .attr("fill", "#000")
            .attr("text-anchor", "start")
            .attr("font-weight", "bold")
            .text(options.legend_opts.title);

          gc.call(d3.axisBottom(x)
              .tickSize(13)
              .tickFormat(function(x, i) {
                if (options.legend_opts.d3_format) {
                  return d3.format(options.legend_opts.d3_format)(x);
                } else {
                  return options.legend_opts.prefix + x + options.legend_opts.suffix;
                }
              })
              .tickValues(color.domain()))
            .select(".domain")
              .remove();
        }

        map = g.append("g")
            .attr("class", "feature")
            .selectAll("path")
            .data(topojson.feature(json, json.objects.states).features)
            .enter().append("path")
              .attr("fill", function(d) { return color(d.properties[options.colors.color_var]); })
              .attr("d", path);



      }

    } else {

      map = g.append("g")
            .attr("class", "feature")
            .selectAll("path")
            .data(topojson.feature(json, json.objects.states).features)
            .enter().append("path")
              .attr("fill", "#5f799c")
              .attr("d", path);

    }

  } else {

    g.append("path")
      .datum(states)
      .attr("class", "feature")
      .attr("d", path);

  }

  if (options !== null) {

    // Zooming
    if (options.zoom) {
      if (options.zoom_opts.click) {
        map.on("click", clicked);
      }
      if (options.zoom_opts.wheel) {
        var zoom = d3.zoom()
          .scaleExtent([1, 8])
          .on("zoom", zoomed);
        svg.call(zoom);
      }
    }

    if (options.tooltip) {

      // Tooltip
      g.selectAll("path")
            .on("mouseover", function(d, i) {
                  d3.select(this).attr("opacity", 0.5);
                  // console.log(options.tooltip_value[i]);
                  if (options.tooltip_value[i] !== null) {
                    div.transition()
                      .duration(200)
                      .style("opacity", 0.9);
                    div.html(options.tooltip_value[i])
                      .style("left", (d3.event.pageX) + "px")
                      .style("top", (d3.event.pageY - 28) + "px");
                  }
                })
            .on("mouseout", function(d) {
                    d3.select(this).attr("opacity", 1);
                    div.transition()
                        .duration(500)
                        .style("opacity", 0);
                });

    }
  }

  if (options !== null) {
    if (typeof options.labs != 'undefined') {
      if (typeof options.labs.title != 'undefined') {
        var title = g.append("g")
            .attr("class", "title")
            .attr("transform", "translate(10,20)");
        title.append("text")
            .attr("class", "title")
            .attr("x", 0)
            .attr("y", -2)
            .attr("fill", "#000")
            .attr("text-anchor", "start")
            .attr("font-weight", "bold")
            .text(options.labs.title);
      }
      if (typeof options.labs.caption != 'undefined') {
        g.append("text")
          .attr("class", "caption")
          .attr("x", width)
          .attr("y", height-5)
          //.attr("startOffset", "100%")
          .attr("text-anchor", "end")
          .attr("font-size", "90%")
          .text(options.labs.caption);
      }
    } else {
      //console.log("nope");
    }
  }

  g.append("path")
      .datum(topojson.mesh(json, json.objects.states, function(a, b) { return a !== b; }))
      .attr("class", "mesh")
      .attr("d", path);

});
