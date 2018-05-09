// D3 maps


r2d3.onRender(function(json, svg, width, height, options) {
  var projection = d3.geoMercator();

  var path = d3.geoPath()
      .projection(projection);

  svg.attr("width", width)
     .attr("height", height);

  var states = topojson.feature(json, json.objects.states);

  // set projection
  projection
      .scale(1)
      .translate([0, 0]);

  var b = path.bounds(states),
      s = 0.9 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height),
      t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2];

  projection
      .scale(s)
      .translate(t);

  // Tooltip
  var div = d3.select("body").append("div")
    .attr("class", "tooltip")
    .style("opacity", 0);


  // continuous colors
  if (options !== null) {
    if (typeof options.colors != 'undefined') {
      if (options.colors.color_type == 'continuous') {
        var x = d3.scaleLinear()
                  .range([1, 200])
                  .domain(options.colors.range_var);
        var color = d3.scaleThreshold()
                      .domain(options.colors.range_col)
                      .range(options.colors.colors);

        if (options.legend) {
          var g = svg.append("g")
            .attr("class", "key")
            .attr("transform", "translate(30," + (height - 30) + ")");

          g.selectAll("rect")
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

          g.append("text")
            .attr("class", "caption")
            .attr("x", -25)
            .attr("y", -6)
            .attr("fill", "#000")
            .attr("text-anchor", "start")
            .attr("font-weight", "bold")
            .text(options.legend_opts.title);

          g.call(d3.axisBottom(x)
              .tickSize(13)
              .tickFormat(function(x, i) { return options.legend_opts.prefix + x + options.legend_opts.suffix; })
              .tickValues(color.domain()))
            .select(".domain")
              .remove();
        }

        svg.append("g")
            .attr("class", "feature")
            .selectAll("path")
            .data(topojson.feature(json, json.objects.states).features)
            .enter().append("path")
              .attr("fill", function(d) { return color(d.properties[options.colors.color_var]); })
              .attr("d", path);



      }
    } else {
      svg.append("g")
            .attr("class", "feature")
            .selectAll("path")
            .data(topojson.feature(json, json.objects.states).features)
            .enter().append("path")
              .attr("fill", "#5f799c")
              .attr("d", path);
    }
  } else {
    svg.append("path")
      .datum(states)
      .attr("class", "feature")
      .attr("d", path);
  }

  if (options !== null) {
    if (options.tooltip) {
      svg.selectAll("path")
            //.data(options.data)
            //.enter().append("path")
            //.attr("d", path)
            .on("mouseover", function(d, i) {
                  d3.select(this).attr("opacity", 0.5);
                  div.transition()
                      .duration(200)
                      .style("opacity", 0.9);
                  div.html(options.tooltip_value[i])
                      .style("left", (d3.event.pageX) + "px")
                      .style("top", (d3.event.pageY - 28) + "px");
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
        var title = svg.append("g")
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
    } else {
      //console.log("nope");
    }
  }

  svg.append("path")
      .datum(topojson.mesh(json, json.objects.states, function(a, b) { return a !== b; }))
      .attr("class", "mesh")
      .attr("d", path);

});
